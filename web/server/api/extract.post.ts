import { YtDlp } from 'ytdlp-nodejs'

const ytdlp = new YtDlp()

interface ExtractBody {
  url: string
  mode: 'info' | 'audio' | 'video'
  // Audio options
  audioFormat?: 'mp3' | 'wav' | 'flac' | 'm4a' | 'opus' | 'vorbis' | 'aac' | 'alac'
  audioQuality?: string
  // Video options
  videoQuality?: 'best' | '2160p' | '1440p' | '1080p' | '720p' | '480p' | '360p' | '240p' | '144p'
  videoFormat?: 'mp4' | 'webm'
  // Common
  flatPlaylist?: boolean
}

export default defineEventHandler(async (event) => {
  const body = await readBody<ExtractBody>(event)

  if (!body?.url) {
    throw createError({ statusCode: 400, statusMessage: 'url is required' })
  }

  const { url, mode = 'info' } = body

  try {
    if (mode === 'info') {
      const info = await ytdlp.getInfoAsync(url, {
        flatPlaylist: body.flatPlaylist ?? true,
      })
      return { success: true, mode, data: info }
    }

    if (mode === 'audio') {
      const format = body.audioFormat ?? 'mp3'
      const result = await ytdlp.downloadAsync(url, {
        format: {
          filter: 'audioonly',
          quality: 5,
          type: format,
        },
        extractAudio: true,
        audioFormat: format,
        audioQuality: body.audioQuality ?? '5',
      })
      return { success: true, mode, data: result }
    }

    if (mode === 'video') {
      const quality = body.videoQuality ?? 'best'
      const type = body.videoFormat ?? 'mp4'
      const result = await ytdlp.downloadAsync(url, {
        format: {
          filter: 'mergevideo',
          quality,
          type,
        },
      })
      return { success: true, mode, data: result }
    }

    throw createError({ statusCode: 400, statusMessage: `Invalid mode: ${mode}` })
  }
  catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error)
    throw createError({ statusCode: 500, statusMessage: message })
  }
})
