import EventSource
import Foundation
import os.log

private let logger = Logger(subsystem: "com.cooked.app", category: "SSE")

/// Events emitted by the import SSE stream.
enum ImportStreamEvent: Sendable {
    case progress(stage: String, message: String)
    case complete(ingredients: [ExtractedIngredient], steps: [String], tags: [String])
    case error(reason: String)
}

/// SSE client for subscribing to recipe extraction progress.
///
/// Connects to `GET /api/recipes/{id}/stream` and yields
/// ``ImportStreamEvent`` values as they arrive from the server.
actor ImportStreamService {
    static let shared = ImportStreamService()

    private let decoder = JSONDecoder()
    private let supabase = SupabaseService.shared
    private let eventSource = EventSource(timeoutInterval: 120)

    /// Opens an SSE connection and yields events as they arrive.
    ///
    /// - Parameter recipeId: The server-side recipe ID to subscribe to
    /// - Returns: An `AsyncThrowingStream` of ``ImportStreamEvent``
    func streamEvents(for recipeId: UUID) -> AsyncThrowingStream<ImportStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            Task { [supabase, eventSource] in
                let endpoint = AppConfig.backendURL
                    .appendingPathComponent("api/recipes/\(recipeId.uuidString)/stream")

                logger.info("[SSE] Connecting to stream: \(endpoint.absoluteString)")

                var request = URLRequest(url: endpoint)
                request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

                // Add auth header
                if let token = try? await supabase.client.auth.session.accessToken {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    logger.debug("[SSE] Auth token added to request")
                } else {
                    logger.warning("[SSE] No auth token available")
                }

                let dataTask = eventSource.dataTask(for: request)

                for await event in dataTask.events() {
                    switch event {
                    case .open:
                        logger.info("[SSE] Stream connected")

                    case .event(let serverEvent):
                        let eventType = serverEvent.event ?? "message"
                        let eventData = serverEvent.data ?? ""

                        logger.debug("[SSE] Event: \(eventType), data length: \(eventData.count)")

                        if let parsed = parseEvent(type: eventType, data: eventData) {
                            logger.info("[SSE] Parsed event: \(eventType)")
                            continuation.yield(parsed)

                            // Terminal events
                            if case .complete = parsed {
                                logger.info("[SSE] Stream complete")
                                continuation.finish()
                                return
                            }
                            if case .error = parsed {
                                logger.error("[SSE] Error event received")
                                continuation.finish()
                                return
                            }
                        }

                    case .error(let error):
                        logger.error("[SSE] Stream error: \(error.localizedDescription)")
                        continuation.finish(throwing: error)
                        return

                    case .closed:
                        logger.info("[SSE] Stream closed")
                        continuation.finish()
                        return
                    }
                }

                // Stream ended without terminal event
                logger.warning("[SSE] Stream ended without complete/error event")
                continuation.finish()
            }
        }
    }

    private func parseEvent(type: String, data: String) -> ImportStreamEvent? {
        guard !data.isEmpty, let jsonData = data.data(using: .utf8) else { return nil }

        switch type {
        case "progress":
            guard let event = try? decoder.decode(ImportProgressEvent.self, from: jsonData) else {
                return nil
            }
            return .progress(stage: event.stage, message: event.message)

        case "complete":
            guard let event = try? decoder.decode(ImportCompleteEvent.self, from: jsonData) else {
                return nil
            }
            return .complete(ingredients: event.ingredients, steps: event.steps, tags: event.tags)

        case "error":
            guard let event = try? decoder.decode(ImportErrorEvent.self, from: jsonData) else {
                return nil
            }
            return .error(reason: event.reason)

        default:
            return nil
        }
    }
}
