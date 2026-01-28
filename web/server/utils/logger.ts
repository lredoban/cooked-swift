import { createConsola } from 'consola'

// Base logger with app-wide configuration
// Log level can be controlled via CONSOLA_LEVEL env var:
// -999 = silent, 0 = error/fatal, 1 = warn, 2 = log, 3 = info (default), 4 = debug, 5 = trace
const baseLogger = createConsola({
  level: process.env.NODE_ENV === 'production' ? 2 : 4, // log level in prod, debug in dev
  formatOptions: {
    date: false, // Nitro already adds timestamps
  },
})

// Tagged loggers for different modules
export const logger = {
  sse: baseLogger.withTag('SSE'),
  jobs: baseLogger.withTag('Jobs'),
  extraction: baseLogger.withTag('Extraction'),
  import: baseLogger.withTag('Import'),
}
