import Foundation
import os.log

private let logger = Logger(subsystem: "com.cooked.app", category: "Import")

enum RecipeSortOption: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case alphabetical = "A-Z"
    case mostCooked = "Most Cooked"

    var id: String { rawValue }
}

/// Extraction progress stage shown during import.
enum ImportStage: Sendable {
    case triggering
    case waitingForStream
    case progress(stage: String, message: String)
    case complete
    case failed(reason: String)
    case backgrounded
}

@Observable
@MainActor
final class RecipeState {
    // MARK: - Recipe Library State

    var recipes: [Recipe] = []
    var isLoading = false
    var error: Error?

    // MARK: - Search & Filter State

    var searchText: String = ""
    var selectedTag: String? = nil
    var sortOption: RecipeSortOption = .recent

    // MARK: - Import Flow State

    var isShowingImportSheet = false
    var importURL = ""

    /// Metadata returned instantly by the trigger endpoint.
    var importMetadata: ImportMetadata?

    /// Current import stage for progress UI.
    var importStage: ImportStage?

    /// The recipe ID being imported (set after trigger).
    var importingRecipeId: UUID?

    /// Error from import trigger or stream.
    var importError: Error?

    /// Whether the preview/progress sheet is showing.
    var isShowingPreview = false

    /// Whether save/confirm is in progress.
    var isSaving = false

    // MARK: - Computed Properties

    var recipeCount: Int { recipes.count }
    var isEmpty: Bool { recipes.isEmpty && !isLoading }

    /// Whether an import is actively in progress.
    var isImporting: Bool {
        guard let stage = importStage else { return false }
        switch stage {
        case .triggering, .waitingForStream, .progress:
            return true
        case .complete, .failed, .backgrounded:
            return false
        }
    }

    /// Recipes currently importing in background.
    var importingRecipes: [Recipe] {
        recipes.filter { $0.importStatus == .importing }
    }

    /// Recipes ready for review.
    var pendingReviewRecipes: [Recipe] {
        recipes.filter { $0.importStatus == .pendingReview }
    }

    /// All unique tags sorted by frequency (most used first)
    var allTags: [String] {
        var tagCounts: [String: Int] = [:]
        for recipe in recipes where recipe.importStatus == .active {
            for tag in recipe.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        return tagCounts.sorted { $0.value > $1.value }.map(\.key)
    }

    /// Recipes filtered by search text and tag, then sorted
    var filteredRecipes: [Recipe] {
        var result = recipes

        // Filter by search text
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { recipe in
                recipe.title.lowercased().contains(query) ||
                recipe.tags.contains { $0.lowercased().contains(query) } ||
                recipe.ingredients.contains { $0.text.lowercased().contains(query) }
            }
        }

        // Filter by selected tag
        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }

        // Sort
        switch sortOption {
        case .recent:
            result.sort { $0.createdAt > $1.createdAt }
        case .alphabetical:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .mostCooked:
            result.sort { $0.timesCooked > $1.timesCooked }
        }

        return result
    }

    private let recipeService = RecipeService.shared
    private let streamService = ImportStreamService.shared
    private var streamTask: Task<Void, Never>?
    private var backgroundTimerTask: Task<Void, Never>?

    // MARK: - Recipe Library Actions

    func loadRecipes() async {
        isLoading = true
        error = nil

        do {
            recipes = try await recipeService.fetchRecipes()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func deleteRecipe(_ recipe: Recipe) async {
        do {
            try await recipeService.deleteRecipe(recipe)
            recipes.removeAll { $0.id == recipe.id }
        } catch {
            self.error = error
        }
    }

    // MARK: - Import Flow Actions

    /// Opens the import sheet.
    func startImport() {
        importURL = ""
        importMetadata = nil
        importStage = nil
        importingRecipeId = nil
        importError = nil
        isShowingImportSheet = true
    }

    /// Triggers the import: calls the server, gets metadata back, opens preview, subscribes to SSE.
    func triggerImport() async {
        guard !importURL.isEmpty else { return }

        logger.info("[Import] 🚀 Triggering import for URL: \(self.importURL)")
        importStage = .triggering
        importError = nil

        do {
            logger.info("[Import] 📤 Calling trigger endpoint...")
            let metadata = try await recipeService.triggerImport(from: importURL)
            logger.info("[Import] ✅ Trigger success - recipeId: \(metadata.recipeId), title: \(metadata.title), platform: \(metadata.platform ?? "unknown")")
            importMetadata = metadata
            importingRecipeId = metadata.recipeId
            importStage = .waitingForStream

            // Dismiss import sheet, show preview
            isShowingImportSheet = false
            isShowingPreview = true

            // Subscribe to SSE stream
            logger.info("[Import] 🔌 Subscribing to SSE stream...")
            subscribeToStream(recipeId: metadata.recipeId)

            // Start background timeout timer
            let platform = metadata.platform
            let timeout = (platform == "tiktok" || platform == "instagram" || platform == "youtube") ? 20 : 8
            logger.info("[Import] ⏱️ Starting background timer: \(timeout)s timeout for platform: \(platform ?? "website")")
            startBackgroundTimer()
        } catch {
            logger.error("[Import] ❌ Trigger failed: \(error.localizedDescription)")
            importError = error
            importStage = .failed(reason: error.localizedDescription)
        }
    }

    /// Subscribes to SSE events for extraction progress.
    private func subscribeToStream(recipeId: UUID) {
        streamTask?.cancel()
        logger.info("[Import] 🔄 Creating new stream subscription for recipe: \(recipeId)")
        streamTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = await streamService.streamEvents(for: recipeId)
                logger.info("[Import] 📡 Stream subscription active, awaiting events...")
                for try await event in stream {
                    await MainActor.run {
                        self.handleStreamEvent(event)
                    }
                }
                logger.info("[Import] ✅ Stream completed normally")
            } catch {
                // Stream ended or failed — fall back to polling
                logger.warning("[Import] ⚠️ Stream failed/ended: \(error.localizedDescription) — falling back to polling")
                await MainActor.run {
                    if self.isImporting {
                        logger.info("[Import] 🔄 Starting polling fallback...")
                        Task { await self.pollForCompletion(recipeId: recipeId) }
                    }
                }
            }
        }
    }

    /// Handles a single SSE event.
    private func handleStreamEvent(_ event: ImportStreamEvent) {
        backgroundTimerTask?.cancel()

        switch event {
        case .progress(let stage, let message):
            logger.info("[Import] 📊 Progress event - stage: \(stage), message: \(message)")
            importStage = .progress(stage: stage, message: message)
            // Reset the background timer on each progress event
            startBackgroundTimer()

        case .complete(let ingredients, let steps, let tags):
            logger.info("[Import] 🎉 Complete event - \(ingredients.count) ingredients, \(steps.count) steps, \(tags.count) tags")
            importStage = .complete
            // Update the local recipe list — fetch the full recipe
            if let recipeId = importingRecipeId {
                Task { await refreshImportedRecipe(id: recipeId) }
            }

        case .error(let reason):
            logger.error("[Import] ❌ Error event: \(reason)")
            importStage = .failed(reason: reason)
        }
    }

    /// Starts a timer that triggers the "background" suggestion after timeout.
    private func startBackgroundTimer() {
        backgroundTimerTask?.cancel()

        let platform = importMetadata?.platform
        let timeout: TimeInterval = (platform == "tiktok" || platform == "instagram" || platform == "youtube") ? 20 : 8

        logger.debug("[Import] ⏱️ Background timer started: \(Int(timeout))s")

        backgroundTimerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(timeout))
            guard !Task.isCancelled, let self else { return }
            await MainActor.run {
                if self.isImporting {
                    logger.info("[Import] ⏰ Background timer fired — suggesting to continue browsing")
                    self.importStage = .backgrounded
                }
            }
        }
    }

    /// Polling fallback when SSE connection drops.
    private func pollForCompletion(recipeId: UUID) async {
        logger.info("[Import] 🔄 Starting polling fallback for recipe: \(recipeId)")
        for attempt in 0..<40 { // ~2 minutes of polling
            try? await Task.sleep(for: .seconds(3))
            guard isImporting else {
                logger.info("[Import] 🛑 Polling stopped — no longer importing")
                return
            }

            logger.debug("[Import] 📡 Poll attempt \(attempt + 1)/40...")
            do {
                let recipe = try await recipeService.fetchRecipe(id: recipeId)
                logger.debug("[Import] 📦 Poll response - status: \(recipe.importStatus.rawValue)")
                if recipe.importStatus == .pendingReview || recipe.importStatus == .active {
                    logger.info("[Import] ✅ Polling found complete recipe!")
                    importStage = .complete
                    updateLocalRecipe(recipe)
                    return
                } else if recipe.importStatus == .failed {
                    logger.error("[Import] ❌ Polling found failed recipe")
                    importStage = .failed(reason: "Extraction failed")
                    return
                }
            } catch {
                logger.warning("[Import] ⚠️ Poll error: \(error.localizedDescription) — continuing...")
                // Keep polling
            }
        }
        logger.error("[Import] ❌ Polling exhausted (40 attempts)")
    }

    /// Fetches the completed recipe and updates the local list.
    private func refreshImportedRecipe(id: UUID) async {
        do {
            let recipe = try await recipeService.fetchRecipe(id: id)
            updateLocalRecipe(recipe)
        } catch {
            // Non-critical — recipe will appear on next loadRecipes()
        }
    }

    /// Updates or inserts a recipe in the local list.
    private func updateLocalRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        } else {
            recipes.insert(recipe, at: 0)
        }
    }

    /// User taps "Continue Browsing" — dismiss preview, extraction continues server-side.
    func backgroundImport() {
        logger.info("[Import] 🏃 User chose to continue browsing — backgrounding import")
        isShowingPreview = false
        importStage = .backgrounded

        // Keep stream subscription alive for notification purposes
        // The recipe will show with an "importing" badge in the list
        if let metadata = importMetadata {
            logger.info("[Import] 📝 Adding placeholder recipe to list: \(metadata.title)")
            let placeholderRecipe = Recipe(
                id: metadata.recipeId,
                userId: UUID(), // Will be corrected on fetch
                title: metadata.title,
                sourceUrl: metadata.sourceUrl,
                sourceName: metadata.sourceName,
                imageUrl: metadata.imageUrl,
                importStatus: .importing
            )
            updateLocalRecipe(placeholderRecipe)
        }
    }

    /// User confirms the imported recipe (review → active).
    func confirmRecipe(userId: UUID, editedTitle: String? = nil) async {
        guard let recipeId = importingRecipeId else {
            logger.warning("[Import] ⚠️ confirmRecipe called but no importingRecipeId")
            return
        }

        logger.info("[Import] 💾 Confirming recipe: \(recipeId), editedTitle: \(editedTitle ?? "(none)")")
        isSaving = true

        do {
            var recipe = try await recipeService.fetchRecipe(id: recipeId)
            logger.debug("[Import] 📦 Fetched recipe - original title: \(recipe.title)")
            recipe.importStatus = .active

            // Update title if user edited it
            if let editedTitle = editedTitle, !editedTitle.isEmpty {
                logger.info("[Import] ✏️ Updating title from '\(recipe.title)' to '\(editedTitle)'")
                recipe.title = editedTitle
            }

            let saved = try await recipeService.updateRecipe(recipe)
            logger.info("[Import] ✅ Recipe saved successfully: \(saved.title)")
            updateLocalRecipe(saved)
            isShowingPreview = false
            resetImportState()
        } catch {
            logger.error("[Import] ❌ Failed to save recipe: \(error.localizedDescription)")
            self.error = error
        }

        isSaving = false
    }

    /// Opens a pending-review recipe for editing.
    func openPendingRecipe(_ recipe: Recipe) {
        importingRecipeId = recipe.id
        importMetadata = ImportMetadata(
            recipeId: recipe.id,
            status: recipe.importStatus.rawValue,
            title: recipe.title,
            sourceName: recipe.sourceName,
            sourceUrl: recipe.sourceUrl ?? "",
            imageUrl: recipe.imageUrl,
            platform: nil
        )
        importStage = .complete
        isShowingPreview = true
    }

    func cancelImport() {
        streamTask?.cancel()
        backgroundTimerTask?.cancel()
        isShowingImportSheet = false
        isShowingPreview = false
        resetImportState()
    }

    private func resetImportState() {
        importMetadata = nil
        importStage = nil
        importingRecipeId = nil
        importURL = ""
        importError = nil
    }

    // MARK: - Filter Actions

    func clearFilters() {
        searchText = ""
        selectedTag = nil
        sortOption = .recent
    }

    func toggleTag(_ tag: String) {
        if selectedTag == tag {
            selectedTag = nil
        } else {
            selectedTag = tag
        }
    }
}
