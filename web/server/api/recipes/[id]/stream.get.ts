import { jobStore } from '../../../utils/jobs'
import { logger } from '../../../utils/logger'

export default defineEventHandler(async (event) => {
  const rawRecipeId = getRouterParam(event, 'id')

  const userId = await requireAuth(event)

  if (!rawRecipeId) {
    logger.sse.warn('❌ Missing recipe ID')
    throw createError({ statusCode: 400, statusMessage: 'Recipe ID is required' })
  }

  // Normalize to lowercase (iOS sends uppercase, Node uses lowercase)
  const recipeId = rawRecipeId.toLowerCase()

  logger.sse.info(`🔌 Client connecting - recipeId: ${recipeId}`)

  // Verify ownership before creating stream
  const job = jobStore.get(recipeId)
  if (job && job.userId !== userId) {
    logger.sse.warn(`❌ Forbidden - job userId mismatch`)
    throw createError({ statusCode: 403, statusMessage: 'Forbidden' })
  }

  logger.sse.debug(`📋 Job status: ${job ? job.status : 'no job in memory'}`)

  const stream = createEventStream(event)

  let closed = false

  const send = async (eventName: string, data: unknown) => {
    if (closed) return
    logger.sse.debug(`📤 Sending event: ${eventName}`)
    await stream.push({
      event: eventName,
      data: JSON.stringify(data)
    })
  }

  const close = async () => {
    if (closed) return
    closed = true
    logger.sse.debug(`🔚 Closing stream`)
    await stream.close()
  }

  // Subscribe to live updates FIRST before replaying to avoid race condition
  const listener = async (eventName: string, data: unknown) => {
    logger.sse.debug(`📡 Listener received: ${eventName}`)
    await send(eventName, data)
    if (eventName === 'complete' || eventName === 'error') {
      logger.sse.info(`🏁 Terminal event, closing`)
      jobStore.unsubscribe(recipeId, listener)
      await close()
    }
  }

  logger.sse.debug(`👂 Subscribing to job events`)
  jobStore.subscribe(recipeId, listener)

  // Clean up on disconnect
  stream.onClosed(async () => {
    logger.sse.info(`🔌 Client disconnected`)
    jobStore.unsubscribe(recipeId, listener)
  })

  // Start async work to replay events and handle completion
  ;(async () => {
    // Send a test event immediately to verify connection
    logger.sse.debug(`✅ Sending test event`)
    await stream.push({
      event: 'test',
      data: JSON.stringify({ message: 'Connection established' })
    })
    // Check if extraction already completed (reconnection case)
    if (job) {
      logger.sse.debug(`🔄 Found job - status: ${job.status}, progress: ${job.progress.length}`)
      // Replay any past progress events
      for (const progress of job.progress) {
        logger.sse.debug(`🔄 Replaying: ${progress.stage}`)
        await send('progress', progress)
      }

      // If already done, emit final event immediately
      if (job.status === 'pending_review' && job.result) {
        logger.sse.info(`✅ Job already complete`)
        await send('complete', job.result)
        await close()
        return
      }
      if (job.status === 'failed') {
        logger.sse.warn(`❌ Job already failed`)
        await send('error', { reason: job.error || 'Extraction failed' })
        await close()
        return
      }
      logger.sse.debug(`⏳ Job in progress, waiting...`)
    } else {
      logger.sse.debug(`🔍 No job in memory, checking DB...`)
      // No in-memory job — check database for already-completed extraction
      const supabase = useSupabaseAdmin()
      const { data: recipe } = await supabase
        .from('recipes')
        .select('status, ingredients, steps, tags')
        .eq('id', recipeId)
        .eq('user_id', userId)
        .single()

      logger.sse.debug(`📦 DB status: ${recipe?.status || 'not found'}`)

      if (recipe?.status === 'pending_review' || recipe?.status === 'active') {
        logger.sse.info(`✅ Recipe complete in DB`)
        await send('complete', {
          ingredients: recipe.ingredients || [],
          steps: recipe.steps || [],
          tags: recipe.tags || []
        })
        await close()
        return
      }

      if (recipe?.status === 'failed') {
        logger.sse.warn(`❌ Recipe failed in DB`)
        await send('error', { reason: 'Extraction failed' })
        await close()
        return
      }

      // Recipe not found or stuck in 'importing' without an active job
      if (!recipe) {
        logger.sse.warn(`❌ Recipe not found`)
        await send('error', { reason: 'Recipe not found' })
        await close()
        return
      }
      if (recipe.status === 'importing') {
        logger.sse.warn(`⚠️ Recipe stuck in importing`)
        await send('error', { reason: 'Extraction expired, please re-import' })
        await close()
        return
      }
    }

    // Re-check job status after subscribing to avoid race condition
    const updatedJob = jobStore.get(recipeId)
    logger.sse.debug(`🔄 Re-check: ${updatedJob?.status || 'no job'}`)
    if (updatedJob?.status === 'pending_review' && updatedJob.result) {
      logger.sse.info(`✅ Job completed during setup`)
      await send('complete', updatedJob.result)
      jobStore.unsubscribe(recipeId, listener)
      await close()
      return
    }
    if (updatedJob?.status === 'failed') {
      logger.sse.warn(`❌ Job failed during setup`)
      await send('error', { reason: updatedJob.error || 'Extraction failed' })
      jobStore.unsubscribe(recipeId, listener)
      await close()
      return
    }
    logger.sse.info(`✅ Stream ready`)
  })().catch(async (err) => {
    logger.sse.error('❌ Async handler error:', err)
    try {
      await send('error', { reason: 'Internal error' })
      await close()
    } catch {
      // Stream may already be closed
    }
  })

  // Return the stream immediately to establish the connection
  return stream.send()
})
