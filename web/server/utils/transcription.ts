import { logger } from './logger'

interface GroqTranscriptionResponse {
  text: string
  language?: string
  duration?: number
  segments?: {
    start: number
    end: number
    text: string
  }[]
}

/**
 * Transcribe audio using Groq Whisper API.
 * Groq provides the fastest Whisper inference (~$0.06/hour).
 */
export async function transcribeAudio(
  audioBuffer: ArrayBuffer,
  filename: string = 'audio.m4a'
): Promise<{ text: string; language?: string } | null> {
  const config = useRuntimeConfig()

  if (!config.groqApiKey) {
    logger.extraction.warn('⚠️ GROQ_API_KEY not configured, skipping transcription')
    return null
  }

  try {
    logger.extraction.info(`🎤 Transcribing audio (${(audioBuffer.byteLength / 1024 / 1024).toFixed(2)} MB)...`)

    // Create form data with the audio file
    const formData = new FormData()
    const blob = new Blob([audioBuffer], { type: getMimeType(filename) })
    formData.append('file', blob, filename)
    formData.append('model', 'whisper-large-v3')
    formData.append('response_format', 'verbose_json')

    const response = await fetch('https://api.groq.com/openai/v1/audio/transcriptions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.groqApiKey}`
      },
      body: formData,
      signal: AbortSignal.timeout(120000) // 2 minute timeout for long videos
    })

    if (!response.ok) {
      const errorText = await response.text()
      logger.extraction.error(`❌ Groq transcription failed: ${response.status} - ${errorText}`)
      return null
    }

    const data = await response.json() as GroqTranscriptionResponse

    logger.extraction.info(`✅ Transcription complete - ${data.text.length} characters, language: ${data.language || 'unknown'}`)

    return {
      text: data.text,
      language: data.language
    }
  } catch (error) {
    logger.extraction.error('❌ Transcription error:', error)
    return null
  }
}

/**
 * Get MIME type from filename extension.
 */
function getMimeType(filename: string): string {
  const ext = filename.split('.').pop()?.toLowerCase()
  const mimeTypes: Record<string, string> = {
    'm4a': 'audio/m4a',
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'webm': 'audio/webm',
    'ogg': 'audio/ogg',
    'mp4': 'audio/mp4',
    'flac': 'audio/flac'
  }
  return mimeTypes[ext || ''] || 'audio/mpeg'
}

/**
 * Download audio from a URL (used for videos that need transcription).
 * Returns the audio buffer for transcription.
 */
export async function downloadAudio(audioUrl: string): Promise<ArrayBuffer | null> {
  try {
    logger.extraction.info(`⬇️ Downloading audio from: ${audioUrl.slice(0, 50)}...`)

    const response = await fetch(audioUrl, {
      signal: AbortSignal.timeout(60000), // 1 minute timeout
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; CookedBot/1.0)'
      }
    })

    if (!response.ok) {
      logger.extraction.error(`❌ Audio download failed: ${response.status}`)
      return null
    }

    const buffer = await response.arrayBuffer()
    logger.extraction.info(`✅ Audio downloaded: ${(buffer.byteLength / 1024 / 1024).toFixed(2)} MB`)

    return buffer
  } catch (error) {
    logger.extraction.error('❌ Audio download error:', error)
    return null
  }
}
