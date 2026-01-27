import type { Platform } from './platform'

interface QuickMetadata {
  title: string
  source_name: string
  image_url: string | null
}

/**
 * Fetches lightweight metadata from a URL using oEmbed or OG tags.
 * Designed to return fast (< 1s) for the import endpoint.
 */
export async function fetchQuickMetadata(url: string, platform: Platform): Promise<QuickMetadata> {
  // Try oEmbed first for video platforms (fastest)
  if (platform === 'youtube' || platform === 'tiktok' || platform === 'instagram') {
    const oembed = await fetchOEmbed(url, platform)
    if (oembed) return oembed
  }

  // Fallback: fetch the page and parse OG tags
  return await fetchOgTags(url)
}

async function fetchOEmbed(url: string, platform: Platform): Promise<QuickMetadata | null> {
  const oembedUrls: Partial<Record<Platform, string>> = {
    youtube: `https://www.youtube.com/oembed?url=${encodeURIComponent(url)}&format=json`,
    tiktok: `https://www.tiktok.com/oembed?url=${encodeURIComponent(url)}`,
    instagram: `https://graph.facebook.com/v18.0/instagram_oembed?url=${encodeURIComponent(url)}&access_token=client`
  }

  const oembedUrl = oembedUrls[platform]
  if (!oembedUrl) return null

  try {
    const res = await fetch(oembedUrl, {
      signal: AbortSignal.timeout(3000)
    })
    if (!res.ok) return null

    const data = (await res.json()) as Record<string, unknown>
    return {
      title: String(data.title || 'Untitled'),
      source_name: String(data.author_name || data.provider_name || ''),
      image_url: typeof data.thumbnail_url === 'string' ? data.thumbnail_url : null
    }
  } catch {
    return null
  }
}

async function fetchOgTags(url: string): Promise<QuickMetadata> {
  const hostname = URL.canParse(url) ? new URL(url).hostname : 'unknown'

  try {
    const res = await fetch(url, {
      signal: AbortSignal.timeout(3000),
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; CookedBot/1.0)'
      }
    })
    if (!res.ok) {
      return { title: 'Untitled', source_name: hostname, image_url: null }
    }

    const html = await res.text()
    const title = extractMeta(html, 'og:title') || extractTag(html, 'title') || 'Untitled'
    const image = extractMeta(html, 'og:image') || null
    const siteName = extractMeta(html, 'og:site_name') || hostname

    return { title, source_name: siteName, image_url: image }
  } catch {
    return { title: 'Untitled', source_name: hostname, image_url: null }
  }
}

function extractMeta(html: string, property: string): string | undefined {
  const re = new RegExp(
    `<meta[^>]+(?:property|name)=["']${property}["'][^>]+content=["']([^"']+)["']`,
    'i'
  )
  const altRe = new RegExp(
    `<meta[^>]+content=["']([^"']+)["'][^>]+(?:property|name)=["']${property}["']`,
    'i'
  )
  return re.exec(html)?.[1] || altRe.exec(html)?.[1]
}

function extractTag(html: string, tag: string): string | undefined {
  const re = new RegExp(`<${tag}[^>]*>([^<]+)</${tag}>`, 'i')
  return re.exec(html)?.[1]?.trim()
}
