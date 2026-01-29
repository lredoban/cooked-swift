import { YtDlp } from 'ytdlp-nodejs'
import { jobStore, type ExtractionResult } from './jobs'
import { logger } from './logger'
import { extractWithLLM } from './llm'
import { persistImage } from './storage'
import { transcribeAudio, downloadAudio } from './transcription'
import { getTikTokInfo, downloadTikTokAudio } from './tiktok'

interface VideoInfo {
  title: string
  description: string
  uploader?: string
  channel?: string
  thumbnail?: string
  subtitles?: Record<string, { url: string, ext: string }[]>
  automatic_captions?: Record<string, { url: string, ext: string }[]>
  requested_subtitles?: Record<string, { url: string, ext: string }>
  formats?: {
    format_id: string
    ext: string
    acodec: string
    vcodec: string
    url: string
    format_note?: string
  }[]
  comments?: {
    text: string
    author: string
  }[]
}

/**
 * Runs the full recipe extraction in the background.
 * Updates the job store with progress, then persists results to Supabase.
 * This function does NOT await — it runs fire-and-forget.
 */
export function startExtraction(recipeId: string, url: string, platform: string) {
  extractRecipe(recipeId, url, platform).catch((err) => {
    logger.extraction.error('💥 Fatal error:', err)
    jobStore.fail(recipeId, 'Internal extraction error')
  })
}

async function extractRecipe(recipeId: string, url: string, platform: string) {
  const supabase = useSupabaseAdmin()
  const startTime = Date.now()

  try {
    // Step 1: Get full video/page info
    jobStore.emitProgress(recipeId, 'fetching_info', 'Fetching video information...')
    logger.extraction.info(`🚀 Starting extraction for ${platform}: ${url}`)

    let description = ''
    let title = ''
    let captions = ''
    let transcript = ''
    let imageUrl: string | null = null
    let sourceName: string | null = null

    // Promise for image persistence - will run in parallel with other work
    let imagePersistPromise: Promise<string | null> = Promise.resolve(null)

    if (platform === 'tiktok') {
      // TikTok: Use TikWM API (more reliable than yt-dlp)
      const infoStart = Date.now()
      const tikTokInfo = await getTikTokInfo(url)
      logger.extraction.info(`📋 TikTok info fetched via TikWM in ${Date.now() - infoStart}ms`)

      description = tikTokInfo.description || ''
      title = tikTokInfo.title || ''
      sourceName = tikTokInfo.author || null
      imageUrl = tikTokInfo.thumbnail || null

      logger.extraction.debug(`📝 Title: ${title.slice(0, 50)}...`)
      logger.extraction.debug(`📝 Description length: ${description.length} chars`)
      logger.extraction.debug(`📷 Thumbnail URL: ${imageUrl ? 'found' : 'not found'}`)

      // Start image download & persistence in parallel
      if (imageUrl) {
        jobStore.emitProgress(recipeId, 'downloading_image', 'Downloading recipe image...')
        logger.extraction.info(`📷 Starting parallel image download: ${imageUrl.slice(0, 60)}...`)
        imagePersistPromise = persistImage(imageUrl, recipeId).catch((err) => {
          logger.extraction.warn(`⚠️ Image persistence failed (non-blocking): ${err}`)
          return null
        })
      }

      // TikTok often needs transcription since description may be sparse
      if (contentIsSparse(description, '')) {
        jobStore.emitProgress(recipeId, 'transcribing', 'Transcribing TikTok audio...')
        try {
          const { buffer } = await downloadTikTokAudio(url, tikTokInfo)
          const transcriptResult = await transcribeAudio(buffer, 'audio.mp3')
          transcript = transcriptResult?.text || ''
          if (transcript) {
            jobStore.emitProgress(recipeId, 'transcription_complete', `Transcribed ${transcript.length} chars`)
            logger.extraction.info(`🎤 TikTok transcription complete: ${transcript.length} chars`)
          }
        } catch (err) {
          logger.extraction.warn(`⚠️ TikTok transcription failed: ${err}`)
        }
      }
    } else if (platform !== 'website') {
      // Other video platforms (YouTube, Instagram) - use yt-dlp
      const infoStart = Date.now()
      const info = await getVideoInfo(url, platform)
      logger.extraction.info(`📋 Video info fetched in ${Date.now() - infoStart}ms`)

      description = info.description || ''
      title = info.title || ''
      sourceName = info.uploader || info.channel || null
      imageUrl = info.thumbnail || null

      logger.extraction.debug(`📝 Title: ${title.slice(0, 50)}...`)
      logger.extraction.debug(`📝 Description length: ${description.length} chars`)
      logger.extraction.debug(`📷 Thumbnail URL: ${imageUrl ? 'found' : 'not found'}`)

      // Start image download & persistence in parallel (fire and forget for now)
      if (imageUrl) {
        jobStore.emitProgress(recipeId, 'downloading_image', 'Downloading recipe image...')
        logger.extraction.info(`📷 Starting parallel image download: ${imageUrl.slice(0, 60)}...`)
        imagePersistPromise = persistImage(imageUrl, recipeId).catch((err) => {
          logger.extraction.warn(`⚠️ Image persistence failed (non-blocking): ${err}`)
          return null
        })
      }

      // Step 2: Extract captions + transcription in parallel where possible
      jobStore.emitProgress(recipeId, 'extracting_content', 'Extracting video content...')

      // Determine if we need transcription (Instagram often has sparse descriptions)
      const needsTranscription = platform === 'instagram'

      // Run captions extraction and (if needed) transcription in parallel
      const contentExtractionStart = Date.now()
      const [captionsResult, transcriptResult] = await Promise.all([
        extractCaptions(info, platform).then((result) => {
          if (result) {
            jobStore.emitProgress(recipeId, 'captions_extracted', `Extracted ${result.length} chars of captions`)
            logger.extraction.info(`📝 Captions extracted: ${result.length} chars`)
          } else {
            logger.extraction.debug(`📝 No captions found for ${platform}`)
          }
          return result
        }),
        needsTranscription
          ? (async () => {
              jobStore.emitProgress(recipeId, 'transcribing', 'Transcribing audio...')
              const result = await transcribeVideo(info)
              if (result) {
                jobStore.emitProgress(recipeId, 'transcription_complete', `Transcribed ${result.length} chars`)
                logger.extraction.info(`🎤 Transcription complete: ${result.length} chars`)
              } else {
                logger.extraction.debug(`🎤 No transcription available`)
              }
              return result
            })()
          : Promise.resolve(null)
      ])

      captions = captionsResult || ''
      transcript = transcriptResult || ''
      logger.extraction.info(`📊 Content extraction completed in ${Date.now() - contentExtractionStart}ms`)

      // For YouTube, check if we need late transcription (sparse content)
      if (platform === 'youtube' && !transcript && contentIsSparse(description, captions)) {
        jobStore.emitProgress(recipeId, 'transcribing', 'Content sparse, transcribing audio...')
        logger.extraction.info(`📊 Content sparse, attempting YouTube transcription`)
        transcript = await transcribeVideo(info) || ''
        if (transcript) {
          jobStore.emitProgress(recipeId, 'transcription_complete', `Transcribed ${transcript.length} chars`)
        }
      }

      // Get comments for Instagram (often has recipe details)
      if (platform === 'instagram' && info.comments?.length) {
        const relevantComments = extractRelevantComments(info.comments)
        if (relevantComments) {
          description += '\n\nComments:\n' + relevantComments
          jobStore.emitProgress(recipeId, 'comments_extracted', `Found ${info.comments.length} relevant comments`)
          logger.extraction.info(`💬 Added ${relevantComments.length} chars from comments`)
        }
      }
    } else {
      // Website: fetch HTML and extract recipe structured data
      jobStore.emitProgress(recipeId, 'scraping_page', 'Scraping recipe page...')
      const pageData = await fetchPageContent(url)
      description = pageData.description
      title = pageData.title
      jobStore.emitProgress(recipeId, 'page_scraped', `Extracted ${description.length} chars from page`)
      logger.extraction.info(`🌐 Page scraped: ${title}`)
    }

    // Log content summary before LLM
    const contentSummary = {
      titleLength: title.length,
      descriptionLength: description.length,
      captionsLength: captions.length,
      transcriptLength: transcript.length,
      totalContent: title.length + description.length + captions.length + transcript.length
    }
    logger.extraction.info(`📊 Content summary: ${JSON.stringify(contentSummary)}`)

    // Step 3: LLM-powered extraction (runs while image is still uploading)
    jobStore.emitProgress(recipeId, 'analyzing', 'AI analyzing recipe content...')
    const llmStart = Date.now()
    logger.extraction.info(`🤖 Starting LLM extraction...`)

    const llmResult = await extractWithLLM(title, description, captions, transcript)

    logger.extraction.info(`🤖 LLM extraction completed in ${Date.now() - llmStart}ms`)
    jobStore.emitProgress(recipeId, 'analysis_complete', `Found ${llmResult.ingredients.length} ingredients, ${llmResult.steps.length} steps`)

    // Use LLM-cleaned title if better
    const cleanedTitle = llmResult.title || title

    // Convert LLM result to job store format
    const result: ExtractionResult = {
      ingredients: llmResult.ingredients.map(ing => ({
        text: ing.text,
        quantity: ing.quantity,
        category: ing.category
      })),
      steps: llmResult.steps,
      tags: llmResult.tags
    }

    // Step 4: Wait for image persistence to complete (should be done or nearly done)
    jobStore.emitProgress(recipeId, 'finalizing_image', 'Finalizing image upload...')
    const imageWaitStart = Date.now()
    const persistedImageUrl = await imagePersistPromise
    if (persistedImageUrl) {
      logger.extraction.info(`📷 Image ready in ${Date.now() - imageWaitStart}ms (waited)`)
    }

    // Step 5: Persist to database
    jobStore.emitProgress(recipeId, 'saving', 'Saving recipe to database...')
    logger.extraction.info(`💾 Saving to database...`)

    const updateData: Record<string, unknown> = {
      status: 'pending_review',
      title: cleanedTitle,
      ingredients: result.ingredients,
      steps: result.steps,
      tags: result.tags
    }

    // Update image URL if we persisted it
    if (persistedImageUrl) {
      updateData.image_url = persistedImageUrl
    }

    // Fix source name for Instagram (was showing "Instagram" instead of creator)
    if (sourceName && platform === 'instagram') {
      updateData.source_name = sourceName
    }

    const { error: updateError } = await supabase
      .from('recipes')
      .update(updateData)
      .eq('id', recipeId)

    if (updateError) {
      logger.extraction.error('❌ DB update failed:', updateError)
      jobStore.fail(recipeId, 'Failed to save extracted data')
      await supabase.from('recipes').update({ status: 'failed' }).eq('id', recipeId)
      return
    }

    const totalTime = Date.now() - startTime
    logger.extraction.info(`✅ Extraction complete in ${totalTime}ms - confidence: ${llmResult.confidence}`)
    logger.extraction.info(`📊 Final: ${result.ingredients.length} ingredients, ${result.steps.length} steps, ${result.tags.length} tags`)
    jobStore.complete(recipeId, result)
  } catch (err) {
    const reason = err instanceof Error ? err.message : 'Extraction failed'
    const totalTime = Date.now() - startTime
    logger.extraction.error(`❌ Error after ${totalTime}ms:`, reason)
    jobStore.fail(recipeId, reason)
    try {
      await supabase
        .from('recipes')
        .update({ status: 'failed' })
        .eq('id', recipeId)
    } catch {
      // Ignore DB error during failure handling
    }
  }
}

/**
 * Get video info using yt-dlp (for YouTube, Instagram).
 * TikTok uses TikWM API instead (see tiktok.ts).
 */
async function getVideoInfo(url: string, platform: string): Promise<VideoInfo> {
  const ytdlp = new YtDlp()

  const rawInfo = await ytdlp.getInfoAsync(url, { flatPlaylist: true })

  if (!rawInfo) {
    throw new Error(`Failed to fetch video info from ${platform}`)
  }

  // Handle array response (playlist) - take first item
  const info = (Array.isArray(rawInfo) ? rawInfo[0] : rawInfo) as Record<string, unknown>

  if (!info || typeof info !== 'object') {
    throw new Error(`Failed to fetch video info from ${platform}`)
  }

  return {
    title: (info.title as string) || '',
    description: (info.description as string) || '',
    uploader: info.uploader as string | undefined,
    channel: info.channel as string | undefined,
    thumbnail: info.thumbnail as string | undefined,
    subtitles: info.subtitles as VideoInfo['subtitles'],
    automatic_captions: info.automatic_captions as VideoInfo['automatic_captions'],
    requested_subtitles: info.requested_subtitles as VideoInfo['requested_subtitles'],
    formats: info.formats as VideoInfo['formats'],
    comments: info.comments as VideoInfo['comments']
  }
}

/**
 * Extract captions/subtitles from video info.
 */
async function extractCaptions(info: VideoInfo, platform: string): Promise<string> {
  // YouTube has automatic captions
  if (platform === 'youtube') {
    const autoCaptions = info.automatic_captions || info.subtitles
    if (!autoCaptions) return ''

    // Prefer English, but take any available
    const langPriority = ['en', 'en-US', 'en-GB']
    let captionUrl: string | null = null
    let captionExt: string = 'vtt'

    for (const lang of langPriority) {
      const tracks = autoCaptions[lang]
      if (tracks?.length) {
        // Prefer vtt or json3 format
        const track = tracks.find(t => t.ext === 'vtt' || t.ext === 'json3') || tracks[0]
        captionUrl = track.url
        captionExt = track.ext
        break
      }
    }

    // Fallback: take any language
    if (!captionUrl) {
      const firstLang = Object.keys(autoCaptions)[0]
      if (firstLang && autoCaptions[firstLang]?.length) {
        const track = autoCaptions[firstLang][0]
        captionUrl = track.url
        captionExt = track.ext
      }
    }

    if (!captionUrl) return ''

    try {
      const response = await fetch(captionUrl, {
        signal: AbortSignal.timeout(10000)
      })
      if (!response.ok) return ''

      const content = await response.text()

      // Parse based on format
      if (captionExt === 'vtt' || captionExt === 'srt') {
        return parseVttToText(content)
      } else if (captionExt === 'json3') {
        return parseJson3ToText(content)
      }

      return content
    } catch {
      logger.extraction.warn('⚠️ Failed to fetch captions')
      return ''
    }
  }

  // TikTok sometimes has captions in a different format
  // For now, we'll rely on description and transcription
  return ''
}

/**
 * Parse VTT/SRT captions to plain text.
 */
function parseVttToText(vtt: string): string {
  // Remove VTT header and timestamps
  const lines = vtt.split('\n')
  const textLines: string[] = []

  for (const line of lines) {
    // Skip WEBVTT header, timestamps, and empty lines
    if (
      line.startsWith('WEBVTT')
      || line.startsWith('Kind:')
      || line.startsWith('Language:')
      || line.includes('-->')
      || /^\d+$/.test(line.trim())
      || !line.trim()
    ) {
      continue
    }

    // Remove VTT tags like <c> </c>
    const cleanLine = line.replace(/<[^>]+>/g, '').trim()
    if (cleanLine && !textLines.includes(cleanLine)) {
      textLines.push(cleanLine)
    }
  }

  return textLines.join(' ')
}

/**
 * Parse YouTube json3 caption format to plain text.
 */
function parseJson3ToText(json: string): string {
  try {
    const data = JSON.parse(json) as { events?: { segs?: { utf8: string }[] }[] }
    if (!data.events) return ''

    const segments: string[] = []
    for (const event of data.events) {
      if (event.segs) {
        for (const seg of event.segs) {
          if (seg.utf8?.trim()) {
            segments.push(seg.utf8.trim())
          }
        }
      }
    }

    return segments.join(' ')
  } catch {
    return ''
  }
}

/**
 * Extract relevant comments that might contain recipe info.
 */
function extractRelevantComments(comments: { text: string, author: string }[]): string {
  const recipeKeywords = [
    'ingredient', 'cup', 'tbsp', 'tsp', 'gram', 'oz', 'ml',
    'recipe', 'step', 'cook', 'bake', 'fry', 'boil', 'mix', 'add', 'minute', 'hour',
    'oven', 'pan', 'pot', 'bowl', 'pinch', 'dash', 'serve'
  ]

  const relevantComments = comments.filter((c) => {
    const lower = c.text.toLowerCase()
    return recipeKeywords.some(kw => lower.includes(kw))
  })

  if (relevantComments.length === 0) return ''

  return relevantComments
    .slice(0, 5) // Max 5 relevant comments
    .map(c => c.text)
    .join('\n')
}

/**
 * Check if extracted content is sparse and might need transcription.
 */
function contentIsSparse(description: string, captions: string): boolean {
  const totalContent = (description + captions).toLowerCase()

  // Check for recipe-related keywords
  const recipeKeywords = [
    'ingredient', 'cup', 'tbsp', 'tsp', 'gram', 'recipe',
    'step', 'cook', 'bake', 'fry', 'boil', 'mix'
  ]

  const keywordCount = recipeKeywords.filter(kw => totalContent.includes(kw)).length

  // If very few keywords and short content, it's sparse
  return keywordCount < 2 && totalContent.length < 500
}

/**
 * Transcribe video audio using Groq Whisper.
 */
async function transcribeVideo(info: VideoInfo): Promise<string | null> {
  const config = useRuntimeConfig()

  if (!config.groqApiKey) {
    logger.extraction.warn('⚠️ Groq API key not configured, skipping transcription')
    return null
  }

  try {
    const formats = info.formats || []

    // First try: audio-only format (best for bandwidth)
    let audioFormat = formats.find(
      f => f.acodec !== 'none' && f.vcodec === 'none'
        && ['m4a', 'mp3', 'webm', 'ogg'].includes(f.ext)
    )

    // Fallback: video with audio (for TikTok which has no audio-only)
    // Pick smallest video file with audio
    if (!audioFormat) {
      const videoWithAudio = formats
        .filter(f => f.acodec !== 'none' && f.acodec !== 'video only' && f.url)
        .sort((a, b) => {
          // Prefer smaller files (less bandwidth)
          const sizeA = (a as Record<string, unknown>).filesize as number || Infinity
          const sizeB = (b as Record<string, unknown>).filesize as number || Infinity
          return sizeA - sizeB
        })

      if (videoWithAudio.length > 0) {
        audioFormat = videoWithAudio[0]
        logger.extraction.info(`📹 Using video format for audio: ${audioFormat.format_id} (no audio-only available)`)
      }
    }

    if (!audioFormat?.url) {
      logger.extraction.warn('⚠️ No suitable audio format found')
      return null
    }

    logger.extraction.debug(`🎵 Audio format: ${audioFormat.format_id}, ext: ${audioFormat.ext}`)

    // Download audio
    const audioBuffer = await downloadAudio(audioFormat.url)
    if (!audioBuffer) return null

    // Transcribe - use mp4 extension for video formats
    const ext = audioFormat.vcodec === 'none' ? audioFormat.ext : 'mp4'
    const result = await transcribeAudio(audioBuffer, `audio.${ext}`)
    return result?.text || null
  } catch (error) {
    logger.extraction.error('❌ Video transcription failed:', error)
    return null
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
  } catch {
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
        if (
          item['@type'] === 'Recipe'
          || (Array.isArray(item['@type']) && (item['@type'] as string[]).includes('Recipe'))
        ) {
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
    } catch {
      /* skip invalid JSON */
    }
  }
  return null
}

function extractMetaContent(html: string, property: string): string | undefined {
  const re = new RegExp(
    `<meta[^>]+(?:property|name)=["']${property}["'][^>]+content=["']([^"']+)["']`,
    'i'
  )
  return re.exec(html)?.[1]
}
