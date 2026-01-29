import { logger } from './logger'

/**
 * Tag taxonomy for recipe classification.
 * LLM will assign tags from these categories only.
 * Note: All tag names must be unique across categories.
 */
export const TAG_TAXONOMY = {
  cuisine: ['italian', 'mexican', 'asian', 'american', 'french', 'indian', 'mediterranean', 'chinese', 'japanese', 'thai', 'korean', 'vietnamese', 'greek', 'spanish', 'middle-eastern'],
  mealType: ['breakfast', 'lunch', 'dinner', 'snack', 'dessert', 'appetizer', 'side-dish', 'drink'],
  diet: ['vegetarian', 'vegan', 'gluten-free', 'keto', 'low-carb', 'dairy-free', 'paleo', 'whole30'],
  time: ['under-30-min', '30-to-60-min', 'over-60-min'],
  difficulty: ['easy', 'intermediate', 'advanced']
} as const

export type IngredientCategory = 'produce' | 'meat' | 'seafood' | 'dairy' | 'pantry' | 'frozen' | 'bakery' | 'other'

export interface ExtractedIngredient {
  text: string
  quantity?: string
  unit?: string
  category: IngredientCategory
}

export interface LLMExtractionResult {
  title: string
  ingredients: ExtractedIngredient[]
  steps: string[]
  tags: string[]
  confidence: number // 0-1 extraction quality
  language?: string // detected source language
}

interface OpenRouterMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

interface OpenRouterResponse {
  choices: {
    message: {
      content: string
    }
  }[]
  usage?: {
    prompt_tokens: number
    completion_tokens: number
    total_tokens: number
  }
}

const EXTRACTION_SYSTEM_PROMPT = `You are a recipe extraction assistant. Extract recipe information from the provided text (which may include video description, captions, or transcription).

IMPORTANT RULES:
1. Extract ingredients with quantities, units, and categorize each for shopping:
   - produce: fruits, vegetables, herbs
   - meat: chicken, beef, pork, lamb
   - seafood: fish, shrimp, shellfish
   - dairy: milk, cheese, butter, eggs, yogurt
   - pantry: oils, spices, flour, sugar, canned goods, pasta, rice
   - frozen: frozen vegetables, frozen fruits, ice cream
   - bakery: bread, tortillas, buns
   - other: anything else

2. Extract cooking steps as clear, actionable instructions. Number them if not already numbered.

3. Assign tags ONLY from this taxonomy (use exact tag names):
   Cuisine: italian, mexican, asian, american, french, indian, mediterranean, chinese, japanese, thai, korean, vietnamese, greek, spanish, middle-eastern
   Meal Type: breakfast, lunch, dinner, snack, dessert, appetizer, side-dish, drink
   Diet: vegetarian, vegan, gluten-free, keto, low-carb, dairy-free, paleo, whole30
   Time: under-30-min, 30-to-60-min, over-60-min
   Difficulty: easy, intermediate, advanced

4. Generate a clear, descriptive recipe title:
   - If the provided title is generic (e.g., "Video by [username]", "Instagram post", "TikTok") or empty, CREATE a descriptive title based on the recipe content (e.g., "Creamy Garlic Pasta", "Spicy Korean Fried Chicken")
   - If the title is already descriptive, clean it up by removing hashtags, excessive emojis, and redundant words like "recipe"
   - The title should clearly describe what dish is being made

5. If the content is not in English, translate everything to English.

6. Set confidence score:
   - 0.9-1.0: Complete recipe with clear ingredients and steps
   - 0.7-0.8: Good recipe info but some gaps
   - 0.5-0.6: Partial info, missing ingredients or steps
   - 0.3-0.4: Minimal recipe info found
   - 0.1-0.2: Almost no recipe content

Respond ONLY with valid JSON matching this schema:
{
  "title": "string",
  "ingredients": [{"text": "string", "quantity": "string or null", "unit": "string or null", "category": "produce|meat|seafood|dairy|pantry|frozen|bakery|other"}],
  "steps": ["string"],
  "tags": ["string"],
  "confidence": 0.0,
  "language": "string (original language code)"
}`

/**
 * Extract recipe data from text content using OpenRouter LLM.
 */
export async function extractWithLLM(
  title: string,
  description: string,
  captions?: string,
  transcript?: string
): Promise<LLMExtractionResult> {
  const config = useRuntimeConfig()

  if (!config.openrouterApiKey) {
    logger.extraction.warn('⚠️ OPENROUTER_API_KEY not configured, falling back to basic extraction')
    return fallbackExtraction(title, description)
  }

  // Combine all text sources
  const textSources: string[] = []
  if (title) textSources.push(`Title: ${title}`)
  if (description) textSources.push(`Description:\n${description}`)
  if (captions) textSources.push(`Video Captions:\n${captions}`)
  if (transcript) textSources.push(`Audio Transcript:\n${transcript}`)

  const combinedText = textSources.join('\n\n---\n\n')

  const messages: OpenRouterMessage[] = [
    { role: 'system', content: EXTRACTION_SYSTEM_PROMPT },
    { role: 'user', content: `Extract the recipe from this content:\n\n${combinedText}` }
  ]

  try {
    logger.extraction.info('🤖 Calling OpenRouter LLM for extraction...')

    const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.openrouterApiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://cooked.wiki',
        'X-Title': 'Cooked Recipe App'
      },
      body: JSON.stringify({
        model: 'openai/gpt-4o-mini',
        messages,
        temperature: 0.3,
        max_tokens: 2000,
        response_format: { type: 'json_object' }
      }),
      signal: AbortSignal.timeout(30000)
    })

    if (!response.ok) {
      const errorText = await response.text()
      logger.extraction.error(`❌ OpenRouter API error: ${response.status} - ${errorText}`)
      return fallbackExtraction(title, description)
    }

    const data = await response.json() as OpenRouterResponse
    const content = data.choices[0]?.message?.content

    if (!content) {
      logger.extraction.error('❌ Empty response from OpenRouter')
      return fallbackExtraction(title, description)
    }

    const result = JSON.parse(content) as LLMExtractionResult

    logger.extraction.info(`✅ LLM extraction complete - ${result.ingredients.length} ingredients, ${result.steps.length} steps, confidence: ${result.confidence}`)
    if (data.usage) {
      logger.extraction.debug(`📊 Tokens used: ${data.usage.total_tokens}`)
    }

    // Validate and sanitize the result
    return sanitizeResult(result)
  } catch (error) {
    logger.extraction.error('❌ LLM extraction failed:', error)
    return fallbackExtraction(title, description)
  }
}

/**
 * Sanitize and validate LLM output.
 */
function sanitizeResult(result: LLMExtractionResult): LLMExtractionResult {
  const validCategories = ['produce', 'meat', 'seafood', 'dairy', 'pantry', 'frozen', 'bakery', 'other'] as const

  return {
    title: result.title?.trim() || 'Untitled Recipe',
    ingredients: (result.ingredients || []).map(ing => ({
      text: ing.text?.trim() || '',
      quantity: ing.quantity?.trim() || undefined,
      unit: ing.unit?.trim() || undefined,
      category: validCategories.includes(ing.category as IngredientCategory)
        ? ing.category
        : 'other'
    })).filter(ing => ing.text.length > 0),
    steps: (result.steps || [])
      .map(s => s?.trim())
      .filter((s): s is string => !!s && s.length > 0),
    tags: (result.tags || [])
      .map(t => t?.toLowerCase().trim())
      .filter((t): t is string => !!t && isValidTag(t)),
    confidence: Math.max(0, Math.min(1, result.confidence || 0.5)),
    language: result.language
  }
}

/**
 * Check if a tag is in our taxonomy.
 */
function isValidTag(tag: string): boolean {
  const allTags = [
    ...TAG_TAXONOMY.cuisine,
    ...TAG_TAXONOMY.mealType,
    ...TAG_TAXONOMY.diet,
    ...TAG_TAXONOMY.time,
    ...TAG_TAXONOMY.difficulty
  ]
  return allTags.includes(tag as typeof allTags[number])
}

/**
 * Basic fallback extraction when LLM is unavailable.
 */
function fallbackExtraction(title: string, description: string): LLMExtractionResult {
  logger.extraction.info('📝 Using fallback regex extraction')

  const ingredients: ExtractedIngredient[] = []
  const steps: string[] = []

  // Simple regex-based extraction (similar to original)
  const lines = description.split('\n').map(l => l.trim()).filter(Boolean)
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
      ingredients.push({ text: cleaned, category: 'other' })
    } else if (section === 'steps' && line.length > 5) {
      const cleaned = line.replace(/^\d+[.)]\s*/, '')
      steps.push(cleaned)
    }
  }

  return {
    title: title.trim() || 'Untitled Recipe',
    ingredients,
    steps,
    tags: [],
    confidence: ingredients.length > 0 || steps.length > 0 ? 0.4 : 0.1
  }
}
