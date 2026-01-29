import { randomUUID } from 'node:crypto'
import { detectPlatform, detectSourceType } from '../../utils/platform'
import { fetchQuickMetadata } from '../../utils/metadata'
import { startExtraction } from '../../utils/extraction'
import { persistImage } from '../../utils/storage'
import { jobStore } from '../../utils/jobs'
import { logger } from '../../utils/logger'

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

  // Persist image immediately (don't wait for background extraction)
  // This ensures the image URL works right away in the iOS app
  let persistedImageUrl = metadata.image_url
  if (metadata.image_url) {
    logger.import.info(`📷 Persisting image for ${recipeId}...`)
    const storedUrl = await persistImage(metadata.image_url, recipeId).catch((err) => {
      logger.import.warn('⚠️ Image persistence failed, using original URL:', err)
      return null
    })
    if (storedUrl) {
      persistedImageUrl = storedUrl
      logger.import.info(`✅ Image persisted: ${storedUrl}`)
    }
  }

  // Persist recipe to database with "importing" status
  const supabase = useSupabaseAdmin()
  const { error: insertError } = await supabase.from('recipes').insert({
    id: recipeId,
    user_id: userId,
    title: metadata.title,
    source_type: sourceType,
    source_url: url,
    source_name: metadata.source_name,
    image_url: persistedImageUrl,
    status: 'importing',
    ingredients: [],
    steps: [],
    tags: [],
    times_cooked: 0
  })

  if (insertError) {
    logger.import.error('❌ DB insert failed:', insertError)
    throw createError({ statusCode: 500, statusMessage: 'Failed to create recipe' })
  }

  // Kick off background extraction (fire-and-forget)
  jobStore.create(recipeId, userId)
  startExtraction(recipeId, url, platform)

  // Return immediately with metadata (including persisted image URL)
  return {
    recipe_id: recipeId,
    status: 'importing',
    title: metadata.title,
    source_name: metadata.source_name,
    source_url: url,
    image_url: persistedImageUrl,
    platform
  }
})
