import Foundation

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

    /// Opens an SSE connection and yields events as they arrive.
    ///
    /// - Parameter recipeId: The server-side recipe ID to subscribe to
    /// - Returns: An `AsyncThrowingStream` of ``ImportStreamEvent``
    func streamEvents(for recipeId: UUID) -> AsyncThrowingStream<ImportStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let endpoint = AppConfig.backendURL
                        .appendingPathComponent("api/recipes/\(recipeId.uuidString)/stream")

                    var request = URLRequest(url: endpoint)
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.timeoutInterval = 120

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        continuation.finish(throwing: RecipeServiceError.networkError)
                        return
                    }

                    var currentEvent = ""
                    var currentData = ""

                    for try await line in bytes.lines {
                        if line.hasPrefix("event:") {
                            currentEvent = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                        } else if line.hasPrefix("data:") {
                            currentData = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                        } else if line.isEmpty {
                            // Empty line = end of event
                            if !currentEvent.isEmpty, !currentData.isEmpty {
                                if let event = parseEvent(type: currentEvent, data: currentData) {
                                    continuation.yield(event)
                                    if case .complete = event {
                                        continuation.finish()
                                        return
                                    }
                                    if case .error = event {
                                        continuation.finish()
                                        return
                                    }
                                }
                            }
                            currentEvent = ""
                            currentData = ""
                        }
                    }

                    // Stream ended without complete/error event
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func parseEvent(type: String, data: String) -> ImportStreamEvent? {
        guard let jsonData = data.data(using: .utf8) else { return nil }

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
