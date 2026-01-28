import { jobStore } from '../../../utils/jobs'

export default defineEventHandler(async (event) => {
  const recipeId = getRouterParam(event, 'id')

  const userId = await requireAuth(event)

  if (!recipeId) {
    throw createError({ statusCode: 400, statusMessage: 'Recipe ID is required' })
  }

  // Verify ownership before creating stream
  const job = jobStore.get(recipeId)
  if (job && job.userId !== userId) {
    throw createError({ statusCode: 403, statusMessage: 'Forbidden' })
  }

  const stream = createEventStream(event)

  const send = async (eventName: string, data: unknown) => {
    await stream.push({
      event: eventName,
      data: JSON.stringify(data)
    })
  }

  const close = async () => {
    await stream.close()
  }

  // Subscribe to live updates FIRST before replaying to avoid race condition
  const listener = async (eventName: string, data: unknown) => {
    await send(eventName, data)
    if (eventName === 'complete' || eventName === 'error') {
      jobStore.unsubscribe(recipeId, listener)
      await close()
    }
  }

  jobStore.subscribe(recipeId, listener)

  // Clean up on disconnect
  stream.onClosed(async () => {
    jobStore.unsubscribe(recipeId, listener)
  })

  // Start async work to replay events and handle completion
  ;(async () => {
    // Send a test event immediately to verify connection
    await stream.push({
      event: 'test',
      data: JSON.stringify({ message: 'Connection established' })
    })
    // Check if extraction already completed (reconnection case)
    if (job) {
      // Replay any past progress events
      for (const progress of job.progress) {
        await send('progress', progress)
      }

      // If already done, emit final event immediately
      if (job.status === 'pending_review' && job.result) {
        await send('complete', job.result)
        await close()
        return
      }
      if (job.status === 'failed') {
        await send('error', { reason: job.error || 'Extraction failed' })
        await close()
        return
      }
    } else {
      // No in-memory job — check database for already-completed extraction
      const supabase = useSupabaseAdmin()
      const { data: recipe } = await supabase
        .from('recipes')
        .select('status, ingredients, steps, tags')
        .eq('id', recipeId)
        .eq('user_id', userId)
        .single()

      if (recipe?.status === 'pending_review' || recipe?.status === 'active') {
        await send('complete', {
          ingredients: recipe.ingredients || [],
          steps: recipe.steps || [],
          tags: recipe.tags || []
        })
        await close()
        return
      }

      if (recipe?.status === 'failed') {
        await send('error', { reason: 'Extraction failed' })
        await close()
        return
      }

      // Recipe not found or stuck in 'importing' without an active job
      if (!recipe) {
        await send('error', { reason: 'Recipe not found' })
        await close()
        return
      }
      if (recipe.status === 'importing') {
        await send('error', { reason: 'Extraction expired, please re-import' })
        await close()
        return
      }
    }

    // Re-check job status after subscribing to avoid race condition
    const updatedJob = jobStore.get(recipeId)
    if (updatedJob?.status === 'pending_review' && updatedJob.result) {
      await send('complete', updatedJob.result)
      jobStore.unsubscribe(recipeId, listener)
      await close()
      return
    }
    if (updatedJob?.status === 'failed') {
      await send('error', { reason: updatedJob.error || 'Extraction failed' })
      jobStore.unsubscribe(recipeId, listener)
      await close()
      return
    }
  })().catch(async (err) => {
    console.error('[stream] Error in async handler:', err)
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
