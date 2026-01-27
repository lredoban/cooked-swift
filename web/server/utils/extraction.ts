import { YtDlp } from 'ytdlp-nodejs'
import { jobStore, type ExtractionResult } from './jobs'

const ytdlp = new YtDlp()

/**
 * Runs the full recipe extraction in the background.
 * Updates the job store with progress, then persists results to Supabase.
 * This function does NOT await — it runs fire-and-forget.
 */
export function startExtraction(recipeId: string, url: string, platform: string) {
  extractRecipe(recipeId, url, platform).catch((err) => {
    console.error(`[extraction] Fatal error for ${recipeId}:`, err)
    jobStore.fail(recipeId, 'Internal extraction error')
  })
}

async function extractRecipe(recipeId: string, url: string, platform: string) {
  const supabase = useSupabaseAdmin()

  try {
    // Step 1: Get full video/page info
    jobStore.emitProgress(recipeId, 'fetching_info', 'Fetching video information...')

    let description = ''
    let title = ''

    if (platform !== 'website') {
      const info = await ytdlp.getInfoAsync(url)
      description = info.description || ''
      title = info.title || ''

      jobStore.emitProgress(recipeId, 'downloading_video', 'Downloading video...')

      // Step 2: Download audio for transcription (if needed in future)
      // For now we extract from description/title metadata
    }
    else {
      // Website: fetch HTML and extract recipe structured data
      jobStore.emitProgress(recipeId, 'scraping_page', 'Scraping recipe page...')
      const pageData = await fetchPageContent(url)
      description = pageData.description
      title = pageData.title
    }

    // Step 3: Parse recipe data from description/content
    jobStore.emitProgress(recipeId, 'extracting_recipe', 'Extracting recipe details...')
    const result = parseRecipeFromText(title, description)

    // Step 4: Persist to database
    jobStore.emitProgress(recipeId, 'saving', 'Saving recipe...')

    const { error: updateError } = await supabase
      .from('recipes')
      .update({
        status: 'pending_review',
        ingredients: result.ingredients,
        steps: result.steps,
        tags: result.tags
      })
      .eq('id', recipeId)

    if (updateError) {
      console.error(`[extraction] DB update failed for ${recipeId}:`, updateError)
      jobStore.fail(recipeId, 'Failed to save extracted data')
      await supabase.from('recipes').update({ status: 'failed' }).eq('id', recipeId)
      return
    }

    jobStore.complete(recipeId, result)
  }
  catch (err) {
    const reason = err instanceof Error ? err.message : 'Extraction failed'
    console.error(`[extraction] Error for ${recipeId}:`, reason)
    jobStore.fail(recipeId, reason)
    await supabase.from('recipes').update({ status: 'failed' }).eq('id', recipeId).catch(() => {})
  }
}

async function fetchPageContent(url: string): Promise<{ title: string, description: string }> {
  try {
    const res = await fetch(url, {
      signal: AbortSignal.timeout(10000),
      headers: { 'User-Agent': 'Mozilla/5.0 (compatible; CookedBot/1.0)' }
    })
    const html = await res.text()

    // Try JSON-LD Recipe schema
    const jsonLd = extractJsonLdRecipe(html)
    if (jsonLd) return jsonLd

    // Fallback to raw text
    const title = extractMetaContent(html, 'og:title') || 'Untitled'
    return { title, description: html.replace(/<[^>]+>/g, ' ').slice(0, 5000) }
  }
  catch {
    return { title: 'Untitled', description: '' }
  }
}

function extractJsonLdRecipe(html: string): { title: string, description: string } | null {
  const scriptRe = /<script[^>]+type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi
  let match: RegExpExecArray | null
  while ((match = scriptRe.exec(html)) !== null) {
    try {
      const data = JSON.parse(match[1]) as Record<string, unknown>
      const items = Array.isArray(data) ? data : [data]
      for (const item of items) {
        if (item['@type'] === 'Recipe' || (Array.isArray(item['@type']) && (item['@type'] as string[]).includes('Recipe'))) {
          return {
            title: String(item.name || 'Untitled'),
            description: JSON.stringify(item)
          }
        }
        // Check @graph
        if (Array.isArray(item['@graph'])) {
          for (const node of item['@graph'] as Record<string, unknown>[]) {
            if (node['@type'] === 'Recipe') {
              return { title: String(node.name || 'Untitled'), description: JSON.stringify(node) }
            }
          }
        }
      }
    }
    catch { /* skip invalid JSON */ }
  }
  return null
}

function extractMetaContent(html: string, property: string): string | undefined {
  const re = new RegExp(`<meta[^>]+(?:property|name)=["']${property}["'][^>]+content=["']([^"']+)["']`, 'i')
  return re.exec(html)?.[1]
}

/**
 * Basic text-based recipe parser.
 * Extracts ingredients, steps, and tags from description text.
 * This is a placeholder — a real implementation would use an LLM or
 * structured data parsing.
 */
function parseRecipeFromText(title: string, text: string): ExtractionResult {
  // Try JSON-LD structured data first
  try {
    const data = JSON.parse(text) as Record<string, unknown>
    return parseStructuredRecipe(data)
  }
  catch { /* not JSON, parse as text */ }

  const lines = text.split('\n').map(l => l.trim()).filter(Boolean)

  const ingredients: ExtractionResult['ingredients'] = []
  const steps: string[] = []
  const tags: string[] = []

  let section: 'unknown' | 'ingredients' | 'steps' = 'unknown'

  for (const line of lines) {
    const lower = line.toLowerCase()

    if (lower.includes('ingredient')) {
      section = 'ingredients'
      continue
    }
    if (lower.includes('instruction') || lower.includes('direction') || lower.includes('method') || lower.includes('step')) {
      section = 'steps'
      continue
    }

    if (section === 'ingredients' && line.length > 2) {
      const cleaned = line.replace(/^[-•*]\s*/, '')
      ingredients.push({ text: cleaned })
    }
    else if (section === 'steps' && line.length > 5) {
      const cleaned = line.replace(/^\d+[.)]\s*/, '')
      steps.push(cleaned)
    }
  }

  // Generate basic tags from title
  const titleWords = title.toLowerCase().split(/\s+/)
  const foodKeywords = ['chicken', 'pasta', 'beef', 'salmon', 'salad', 'soup', 'cake', 'bread', 'rice', 'pizza', 'tacos', 'curry', 'steak', 'shrimp', 'tofu', 'vegan', 'vegetarian', 'dessert', 'breakfast', 'lunch', 'dinner']
  for (const word of titleWords) {
    if (foodKeywords.includes(word)) {
      tags.push(word)
    }
  }

  return { ingredients, steps, tags }
}

function parseStructuredRecipe(data: Record<string, unknown>): ExtractionResult {
  const ingredients: ExtractionResult['ingredients'] = []
  const steps: string[] = []
  const tags: string[] = []

  // Parse ingredients
  const rawIngredients = data.recipeIngredient as string[] | undefined
  if (Array.isArray(rawIngredients)) {
    for (const ing of rawIngredients) {
      ingredients.push({ text: String(ing) })
    }
  }

  // Parse instructions
  const rawInstructions = data.recipeInstructions as unknown[] | undefined
  if (Array.isArray(rawInstructions)) {
    for (const step of rawInstructions) {
      if (typeof step === 'string') {
        steps.push(step)
      }
      else if (step && typeof step === 'object' && 'text' in step) {
        steps.push(String((step as Record<string, unknown>).text))
      }
    }
  }

  // Parse category/tags
  const category = data.recipeCategory
  if (typeof category === 'string') tags.push(category)
  if (Array.isArray(category)) tags.push(...category.map(String))

  const cuisine = data.recipeCuisine
  if (typeof cuisine === 'string') tags.push(cuisine)
  if (Array.isArray(cuisine)) tags.push(...cuisine.map(String))

  const keywords = data.keywords
  if (typeof keywords === 'string') tags.push(...keywords.split(',').map(k => k.trim()))
  if (Array.isArray(keywords)) tags.push(...keywords.map(String))

  return { ingredients, steps, tags }
}
