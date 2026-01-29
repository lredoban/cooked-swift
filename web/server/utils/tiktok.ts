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
 * Fetch TikTok video info using TikWM API
 */
export async function getTikTokInfo(url: string): Promise<TikTokVideoInfo> {
  const cleanUrl = cleanTikTokUrl(url)
  logger.extraction.info(`🎵 Fetching TikTok info via TikWM: ${cleanUrl}`)

  const apiUrl = `https://www.tikwm.com/api/?url=${encodeURIComponent(cleanUrl)}`

  const response = await fetch(apiUrl, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
      Accept: 'application/json'
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

  return {
    id: data.id,
    title: data.title,
    description: data.content_desc?.join('\n') || data.title,
    thumbnail: data.origin_cover || data.cover,
    videoUrl: data.hdplay || data.play,
    audioUrl: data.music,
    author: data.author.nickname,
    authorUsername: data.author.unique_id,
    duration: data.duration
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
      Referer: 'https://www.tiktok.com/'
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
