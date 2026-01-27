import { jobStore } from '../../../utils/jobs'

export default defineEventHandler(async (event) => {
  const userId = await requireAuth(event)

  const recipeId = getRouterParam(event, 'id')
  if (!recipeId) {
    throw createError({ statusCode: 400, statusMessage: 'Recipe ID is required' })
  }

  // Set SSE headers
  setResponseHeaders(event, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    Connection: 'keep-alive'
  })

  const res = event.node.res

  const send = (eventName: string, data: unknown) => {
    res.write(`event: ${eventName}\ndata: ${JSON.stringify(data)}\n\n`)
  }

  // Check if extraction already completed (reconnection case)
  const job = jobStore.get(recipeId)
  if (job) {
    if (job.userId !== userId) {
      throw createError({ statusCode: 403, statusMessage: 'Forbidden' })
    }
    // Replay any past progress events
    for (const progress of job.progress) {
      send('progress', progress)
    }

    // If already done, emit final event immediately
    if (job.status === 'pending_review' && job.result) {
      send('complete', job.result)
      res.end()
      return
    }
    if (job.status === 'failed') {
      send('error', { reason: job.error || 'Extraction failed' })
      res.end()
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
      send('complete', {
        ingredients: recipe.ingredients || [],
        steps: recipe.steps || [],
        tags: recipe.tags || []
      })
      res.end()
      return
    }

    if (recipe?.status === 'failed') {
      send('error', { reason: 'Extraction failed' })
      res.end()
      return
    }
  }

  // Subscribe to live updates
  const listener = (eventName: string, data: unknown) => {
    send(eventName, data)
    if (eventName === 'complete' || eventName === 'error') {
      res.end()
    }
  }

  jobStore.subscribe(recipeId, listener)

  // Re-check job status after subscribing to avoid race condition
  // (job may have completed between initial check and subscribe)
  const updatedJob = jobStore.get(recipeId)
  if (updatedJob?.status === 'pending_review' && updatedJob.result) {
    send('complete', updatedJob.result)
    jobStore.unsubscribe(recipeId, listener)
    res.end()
    return
  }
  if (updatedJob?.status === 'failed') {
    send('error', { reason: updatedJob.error || 'Extraction failed' })
    jobStore.unsubscribe(recipeId, listener)
    res.end()
    return
  }

  // Clean up on disconnect
  res.on('close', () => {
    jobStore.unsubscribe(recipeId, listener)
  })

  // Keep-alive ping every 30s
  const keepAlive = setInterval(() => {
    if (!res.closed) {
      res.write(': keepalive\n\n')
    } else {
      clearInterval(keepAlive)
    }
  }, 30000)

  res.on('close', () => clearInterval(keepAlive))
})
