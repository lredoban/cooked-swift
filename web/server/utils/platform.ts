export type Platform = 'youtube' | 'tiktok' | 'instagram' | 'website'

const PLATFORM_PATTERNS: [RegExp, Platform][] = [
  [/(?:youtube\.com|youtu\.be)/i, 'youtube'],
  [/tiktok\.com/i, 'tiktok'],
  [/instagram\.com/i, 'instagram']
]

/**
 * Detects the platform from a URL.
 */
export function detectPlatform(url: string): Platform {
  for (const [pattern, platform] of PLATFORM_PATTERNS) {
    if (pattern.test(url)) return platform
  }
  return 'website'
}

/**
 * Determines the source_type for the recipe model.
 */
export function detectSourceType(platform: Platform): 'video' | 'url' {
  return platform === 'website' ? 'url' : 'video'
}
