import { randomUUID } from 'node:crypto'
import { detectPlatform, detectSourceType } from '../../utils/platform'
import { fetchQuickMetadata } from '../../utils/metadata'
import { startExtraction } from '../../utils/extraction'
import { jobStore } from '../../utils/jobs'

interface ImportBody {
  url: string
  source_type?: string
}

export default defineEventHandler(async (event) => {
  const userId = await requireAuth(event)
  const body = await readBody<ImportBody>(event)

  if (!body?.url) {
    throw createError({ statusCode: 400, statusMessage: 'url is required' })
  }

  const { url } = body
  const platform = detectPlatform(url)
  const sourceType = body.source_type || detectSourceType(platform)
  const recipeId = randomUUID()

  // Fetch lightweight metadata (must be fast, < 1s target)
  const metadata = await fetchQuickMetadata(url, platform)

  // Persist recipe to database with "importing" status
  const supabase = useSupabaseAdmin()
  const { error: insertError } = await supabase.from('recipes').insert({
    id: recipeId,
    user_id: userId,
    title: metadata.title,
    source_type: sourceType,
    source_url: url,
    source_name: metadata.source_name,
    image_url: metadata.image_url,
    status: 'importing',
    ingredients: [],
    steps: [],
    tags: [],
    times_cooked: 0
  })

  if (insertError) {
    console.error('[import] DB insert failed:', insertError)
    throw createError({ statusCode: 500, statusMessage: 'Failed to create recipe' })
  }

  // Kick off background extraction (fire-and-forget)
  jobStore.create(recipeId, userId)
  startExtraction(recipeId, url, platform)

  // Return immediately with metadata
  return {
    recipe_id: recipeId,
    status: 'importing',
    title: metadata.title,
    source_name: metadata.source_name,
    source_url: url,
    image_url: metadata.image_url,
    platform
  }
})
