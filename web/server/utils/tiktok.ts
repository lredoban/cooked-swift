/**
 * TikTok video info fetcher using TikWM API
 * This is a reliable alternative to yt-dlp for TikTok
 */

import { logger } from './logger'

interface TikWMResponse {
  code: number
  msg: string
  data: {
    id: string
    region: string
    title: string
    content_desc?: string[]
    cover: string
    origin_cover: string
    duration: number
    play: string // Video URL (watermarked)
    hdplay?: string // HD video URL
    music: string // Audio URL
    music_info?: {
      title: string
      author: string
    }
    author: {
      id: string
      unique_id: string
      nickname: string
      avatar: string
    }
  } | null
}

export interface TikTokVideoInfo {
  id: string
  title: string
  description: string
  thumbnail: string
  videoUrl: string
  audioUrl: string
  author: string
  authorUsername: string
  duration: number
}

/**
 * Clean TikTok URL by removing tracking parameters
 */
function cleanTikTokUrl(url: string): string {
  try {
    const parsed = new URL(url)
    parsed.search = ''
    return parsed.toString()
  } catch {
    return url
  }
}

/**
 * Fetch TikTok video info using TikWM API, with fallback to direct page scraping
 */
export async function getTikTokInfo(url: string): Promise<TikTokVideoInfo> {
  const cleanUrl = cleanTikTokUrl(url)
  logger.extraction.info(`🎵 Fetching TikTok info via TikWM: ${cleanUrl}`)

  const apiUrl = `https://www.tikwm.com/api/?url=${encodeURIComponent(cleanUrl)}`

  const response = await fetch(apiUrl, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      'Accept': 'application/json'
    },
    signal: AbortSignal.timeout(30000)
  })

  if (!response.ok) {
    throw new Error(`TikWM API error: ${response.status}`)
  }

  const result = (await response.json()) as TikWMResponse

  if (result.code !== 0 || !result.data) {
    throw new Error(`TikWM API failed: ${result.msg}`)
  }

  const data = result.data

  // TikWM often returns empty content_desc - try to get full description from page
  let description = data.content_desc?.join('\n') || ''
  if (!description || description === data.title) {
    logger.extraction.info(`🎵 TikWM description empty, fetching from TikTok page...`)
    const pageDescription = await fetchTikTokPageDescription(cleanUrl)
    if (pageDescription && pageDescription.length > description.length) {
      description = pageDescription
      logger.extraction.info(`🎵 Got description from page: ${description.length} chars`)
    }
  }

  return {
    id: data.id,
    title: data.title,
    description: description || data.title,
    thumbnail: data.origin_cover || data.cover,
    videoUrl: data.hdplay || data.play,
    audioUrl: data.music,
    author: data.author.nickname,
    authorUsername: data.author.unique_id,
    duration: data.duration
  }
}

/**
 * Fetch TikTok page and extract description from embedded data.
 * Extracts video text overlays (stickers) which often contain recipe ingredients.
 */
async function fetchTikTokPageDescription(url: string): Promise<string | null> {
  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9'
      },
      signal: AbortSignal.timeout(15000)
    })

    if (!response.ok) {
      logger.extraction.warn(`⚠️ TikTok page fetch failed: ${response.status}`)
      return null
    }

    const html = await response.text()

    // Try to extract from __UNIVERSAL_DATA_FOR_REHYDRATION__ script
    const universalDataMatch = html.match(/<script[^>]*id="__UNIVERSAL_DATA_FOR_REHYDRATION__"[^>]*>([^<]+)<\/script>/)
    if (universalDataMatch) {
      try {
        const data = JSON.parse(universalDataMatch[1])
        const videoDetail = data?.['__DEFAULT_SCOPE__']?.['webapp.video-detail']
        const itemInfo = videoDetail?.itemInfo?.itemStruct

        if (itemInfo) {
          const descParts: string[] = []

          // Extract text from video stickers/overlays - this often has ingredients!
          if (itemInfo.stickersOnItem && Array.isArray(itemInfo.stickersOnItem)) {
            const stickerTexts: string[] = []
            for (const sticker of itemInfo.stickersOnItem) {
              if (sticker.stickerText && Array.isArray(sticker.stickerText)) {
                stickerTexts.push(...sticker.stickerText)
              }
            }
            if (stickerTexts.length > 0) {
              const stickerContent = stickerTexts.join('\n')
              descParts.push(`Video text overlays:\n${stickerContent}`)
              logger.extraction.info(`🎵 Found ${stickerTexts.length} text overlays from video stickers`)
            }
          }

          // Add the regular description
          if (itemInfo.desc) {
            descParts.push(`Description:\n${itemInfo.desc}`)
          }

          // Check AIGCDescription (AI-generated content)
          if (itemInfo.AIGCDescription) {
            descParts.push(`AI Description:\n${itemInfo.AIGCDescription}`)
          }

          if (descParts.length > 0) {
            return descParts.join('\n\n')
          }
        }
      } catch (e) {
        logger.extraction.warn(`⚠️ Failed to parse TikTok page data: ${e}`)
      }
    }

    // Fallback: try SIGI_STATE
    const sigiMatch = html.match(/<script[^>]*id="SIGI_STATE"[^>]*>([^<]+)<\/script>/)
    if (sigiMatch) {
      try {
        const data = JSON.parse(sigiMatch[1])
        const itemModule = data?.ItemModule
        if (itemModule) {
          const firstItem = Object.values(itemModule)[0] as { desc?: string }
          if (firstItem?.desc) {
            return firstItem.desc
          }
        }
      } catch {
        // Ignore parse errors
      }
    }

    // Fallback: try og:description meta tag
    const ogDescMatch = html.match(/<meta[^>]+property="og:description"[^>]+content="([^"]+)"/)
    if (ogDescMatch) {
      return ogDescMatch[1]
    }

    return null
  } catch (error) {
    logger.extraction.warn(`⚠️ TikTok page scraping failed: ${error}`)
    return null
  }
}

/**
 * Download TikTok audio and return as buffer
 * @param url - TikTok video URL
 * @param existingInfo - Optional pre-fetched info to avoid duplicate API call
 */
export async function downloadTikTokAudio(url: string, existingInfo?: TikTokVideoInfo): Promise<{ buffer: Buffer; info: TikTokVideoInfo }> {
  const info = existingInfo ?? await getTikTokInfo(url)

  logger.extraction.info(`🎵 Downloading TikTok audio: ${info.audioUrl.slice(0, 60)}...`)

  const response = await fetch(info.audioUrl, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      'Referer': 'https://www.tiktok.com/'
    },
    signal: AbortSignal.timeout(60000)
  })

  if (!response.ok) {
    throw new Error(`Failed to download TikTok audio: ${response.status}`)
  }

  const arrayBuffer = await response.arrayBuffer()
  const buffer = Buffer.from(arrayBuffer)

  logger.extraction.info(`🎵 TikTok audio downloaded: ${buffer.length} bytes`)

  return { buffer, info }
}
