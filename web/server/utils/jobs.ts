import { logger } from './logger'

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
  userId: string
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

  create(recipeId: string, userId: string): Job {
    logger.jobs.info(`📝 Creating job - recipeId: ${recipeId}`)
    const job: Job = {
      recipeId,
      userId,
      status: 'importing',
      progress: [],
      result: null,
      error: null
    }
    this.jobs.set(recipeId, job)
    logger.jobs.debug(`✅ Job created - active: ${this.jobs.size}`)
    return job
  }

  get(recipeId: string): Job | undefined {
    const job = this.jobs.get(recipeId)
    logger.jobs.debug(`🔍 Get job: ${job ? job.status : 'not found'}`)
    return job
  }

  emitProgress(recipeId: string, stage: string, message: string) {
    const job = this.jobs.get(recipeId)
    if (!job) {
      logger.jobs.warn(`⚠️ emitProgress: no job for ${recipeId}`)
      return
    }

    logger.jobs.debug(`📊 Progress - ${stage}: ${message}`)
    const event: ProgressEvent = { stage, message }
    job.progress.push(event)
    this.notify(recipeId, 'progress', event)
  }

  complete(recipeId: string, result: ExtractionResult) {
    const job = this.jobs.get(recipeId)
    if (!job) {
      logger.jobs.warn(`⚠️ complete: no job for ${recipeId}`)
      return
    }

    logger.jobs.info(`🎉 Complete - ingredients: ${result.ingredients.length}, steps: ${result.steps.length}`)
    job.status = 'pending_review'
    job.result = result
    this.notify(recipeId, 'complete', result)

    // Clean up after 10 minutes
    setTimeout(() => this.cleanup(recipeId), 10 * 60 * 1000)
  }

  fail(recipeId: string, reason: string) {
    const job = this.jobs.get(recipeId)
    if (!job) {
      logger.jobs.warn(`⚠️ fail: no job for ${recipeId}`)
      return
    }

    logger.jobs.error(`❌ Failed - ${reason}`)
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
    logger.jobs.debug(`👂 Subscribed - listeners: ${this.listeners.get(recipeId)!.size}`)
  }

  unsubscribe(recipeId: string, listener: JobListener) {
    this.listeners.get(recipeId)?.delete(listener)
    logger.jobs.debug(`🔇 Unsubscribed - remaining: ${this.listeners.get(recipeId)?.size || 0}`)
  }

  private cleanup(recipeId: string) {
    logger.jobs.debug(`🧹 Cleaning up: ${recipeId}`)
    this.jobs.delete(recipeId)
    this.listeners.delete(recipeId)
  }

  private notify(recipeId: string, event: string, data: unknown) {
    const listeners = this.listeners.get(recipeId)
    if (!listeners) {
      logger.jobs.debug(`⚠️ No listeners`)
      return
    }
    logger.jobs.debug(`📢 Notifying ${listeners.size} listener(s) of '${event}'`)
    for (const listener of listeners) {
      Promise.resolve(listener(event, data)).catch((err) => {
        logger.jobs.error('❌ Listener error:', err)
      })
    }
  }
}

export const jobStore = new JobStore()
