import { logger } from './logger'

/**
 * Download an image from a URL and upload it to Supabase Storage.
 * Returns the permanent public URL.
 */
export async function persistImage(
  imageUrl: string,
  recipeId: string
): Promise<string | null> {
  const config = useRuntimeConfig()

  if (!config.public.supabaseUrl || !config.supabaseServiceKey) {
    logger.extraction.warn('⚠️ Supabase not configured, skipping image persistence')
    return null
  }

  try {
    logger.extraction.info(`📷 Downloading image from: ${imageUrl.slice(0, 50)}...`)

    // Download the image
    const response = await fetch(imageUrl, {
      signal: AbortSignal.timeout(15000),
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; CookedBot/1.0)'
      }
    })

    if (!response.ok) {
      logger.extraction.error(`❌ Failed to download image: ${response.status}`)
      return null
    }

    const contentType = response.headers.get('content-type') || 'image/jpeg'
    const extension = getExtensionFromMimeType(contentType)
    const imageBuffer = await response.arrayBuffer()

    // Generate a unique filename
    const filename = `${recipeId}.${extension}`
    const storagePath = `recipe-images/${filename}`

    logger.extraction.info(`📤 Uploading to Supabase Storage: ${storagePath}`)

    // Upload to Supabase Storage using REST API
    // Supabase requires both apikey header and Authorization bearer token
    const uploadUrl = `${config.public.supabaseUrl}/storage/v1/object/recipe-images/${filename}`
    const uploadResponse = await fetch(uploadUrl, {
      method: 'POST',
      headers: {
        'apikey': config.supabaseServiceKey,
        'Authorization': `Bearer ${config.supabaseServiceKey}`,
        'Content-Type': contentType,
        'x-upsert': 'true' // Overwrite if exists
      },
      body: imageBuffer
    })

    if (!uploadResponse.ok) {
      const errorText = await uploadResponse.text()
      logger.extraction.error(`❌ Supabase Storage upload failed: ${uploadResponse.status} - ${errorText}`)
      return null
    }

    // Return the public URL
    const publicUrl = `${config.public.supabaseUrl}/storage/v1/object/public/recipe-images/${filename}`
    logger.extraction.info(`✅ Image persisted: ${publicUrl}`)

    return publicUrl
  } catch (error) {
    logger.extraction.error('❌ Image persistence failed:', error)
    return null
  }
}

/**
 * Get file extension from MIME type.
 */
function getExtensionFromMimeType(mimeType: string): string {
  const map: Record<string, string> = {
    'image/jpeg': 'jpg',
    'image/jpg': 'jpg',
    'image/png': 'png',
    'image/webp': 'webp',
    'image/gif': 'gif',
    'image/avif': 'avif'
  }
  return map[mimeType.toLowerCase()] || 'jpg'
}

/**
 * Delete an image from Supabase Storage.
 */
export async function deleteImage(recipeId: string): Promise<boolean> {
  const config = useRuntimeConfig()

  if (!config.public.supabaseUrl || !config.supabaseServiceKey) {
    return false
  }

  try {
    // Try common extensions
    const extensions = ['jpg', 'png', 'webp', 'gif']

    for (const ext of extensions) {
      const filename = `${recipeId}.${ext}`
      const deleteUrl = `${config.public.supabaseUrl}/storage/v1/object/recipe-images/${filename}`

      const response = await fetch(deleteUrl, {
        method: 'DELETE',
        headers: {
          'apikey': config.supabaseServiceKey,
          'Authorization': `Bearer ${config.supabaseServiceKey}`
        }
      })

      if (response.ok) {
        logger.extraction.info(`🗑️ Deleted image: ${filename}`)
        return true
      }
    }

    return false
  } catch (error) {
    logger.extraction.error('❌ Image deletion failed:', error)
    return false
  }
}
