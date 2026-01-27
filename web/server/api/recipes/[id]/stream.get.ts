import { jobStore } from '../../../utils/jobs'

export default defineEventHandler(async (event) => {
  const userId = await requireAuth(event)

  const recipeId = getRouterParam(event, 'id')
  if (!recipeId) {
    throw createError({ statusCode: 400, statusMessage: 'Recipe ID is required' })
  }

  const stream = createEventStream(event)

  const send = async (eventName: string, data: unknown) => {
    await stream.push(`event: ${eventName}\ndata: ${JSON.stringify(data)}\n\n`)
  }

  const close = async () => {
    await stream.close()
  }

  // Check if extraction already completed (reconnection case)
  const job = jobStore.get(recipeId)
  if (job) {
    if (job.userId !== userId) {
      throw createError({ statusCode: 403, statusMessage: 'Forbidden' })
    }
    // Replay any past progress events
    for (const progress of job.progress) {
      await send('progress', progress)
    }

    // If already done, emit final event immediately
    if (job.status === 'pending_review' && job.result) {
      await send('complete', job.result)
      await close()
      return stream.send()
    }
    if (job.status === 'failed') {
      await send('error', { reason: job.error || 'Extraction failed' })
      await close()
      return stream.send()
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
      return stream.send()
    }

    if (recipe?.status === 'failed') {
      await send('error', { reason: 'Extraction failed' })
      await close()
      return stream.send()
    }
  }

  // Subscribe to live updates
  const listener = async (eventName: string, data: unknown) => {
    await send(eventName, data)
    if (eventName === 'complete' || eventName === 'error') {
      jobStore.unsubscribe(recipeId, listener)
      await close()
    }
  }

  jobStore.subscribe(recipeId, listener)

  // Re-check job status after subscribing to avoid race condition
  const updatedJob = jobStore.get(recipeId)
  if (updatedJob?.status === 'pending_review' && updatedJob.result) {
    await send('complete', updatedJob.result)
    jobStore.unsubscribe(recipeId, listener)
    await close()
    return stream.send()
  }
  if (updatedJob?.status === 'failed') {
    await send('error', { reason: updatedJob.error || 'Extraction failed' })
    jobStore.unsubscribe(recipeId, listener)
    await close()
    return stream.send()
  }

  // Clean up on disconnect
  stream.onClosed(async () => {
    jobStore.unsubscribe(recipeId, listener)
  })

  return stream.send()
})
