export interface ExtractionResult {
  ingredients: { text: string; quantity?: string }[]
  steps: string[]
  tags: string[]
}

export interface ProgressEvent {
  stage: string
  message: string
}

export interface Job {
  recipeId: string
  status: 'importing' | 'pending_review' | 'failed'
  progress: ProgressEvent[]
  result: ExtractionResult | null
  error: string | null
}

type JobListener = (event: string, data: unknown) => void

/**
 * In-memory store for extraction jobs.
 * Tracks progress, results, and SSE listeners per recipe.
 * On completion, persists data to Supabase and cleans up after a delay.
 */
class JobStore {
  private jobs = new Map<string, Job>()
  private listeners = new Map<string, Set<JobListener>>()

  create(recipeId: string): Job {
    const job: Job = {
      recipeId,
      status: 'importing',
      progress: [],
      result: null,
      error: null
    }
    this.jobs.set(recipeId, job)
    return job
  }

  get(recipeId: string): Job | undefined {
    return this.jobs.get(recipeId)
  }

  emitProgress(recipeId: string, stage: string, message: string) {
    const job = this.jobs.get(recipeId)
    if (!job) return

    const event: ProgressEvent = { stage, message }
    job.progress.push(event)
    this.notify(recipeId, 'progress', event)
  }

  complete(recipeId: string, result: ExtractionResult) {
    const job = this.jobs.get(recipeId)
    if (!job) return

    job.status = 'pending_review'
    job.result = result
    this.notify(recipeId, 'complete', result)

    // Clean up after 10 minutes
    setTimeout(() => this.cleanup(recipeId), 10 * 60 * 1000)
  }

  fail(recipeId: string, reason: string) {
    const job = this.jobs.get(recipeId)
    if (!job) return

    job.status = 'failed'
    job.error = reason
    this.notify(recipeId, 'error', { reason })

    setTimeout(() => this.cleanup(recipeId), 10 * 60 * 1000)
  }

  subscribe(recipeId: string, listener: JobListener) {
    if (!this.listeners.has(recipeId)) {
      this.listeners.set(recipeId, new Set())
    }
    this.listeners.get(recipeId)!.add(listener)
  }

  unsubscribe(recipeId: string, listener: JobListener) {
    this.listeners.get(recipeId)?.delete(listener)
  }

  private cleanup(recipeId: string) {
    this.jobs.delete(recipeId)
    this.listeners.delete(recipeId)
  }

  private notify(recipeId: string, event: string, data: unknown) {
    const listeners = this.listeners.get(recipeId)
    if (!listeners) return
    for (const listener of listeners) {
      listener(event, data)
    }
  }
}

export const jobStore = new JobStore()
