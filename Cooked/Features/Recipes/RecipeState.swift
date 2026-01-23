import Foundation

enum RecipeSortOption: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case alphabetical = "A-Z"
    case mostCooked = "Most Cooked"

    var id: String { rawValue }
}

@Observable
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
    var isExtracting = false
    var extractedRecipe: ExtractedRecipe?
    var extractionError: Error?
    var isShowingPreview = false
    var isSaving = false

    // MARK: - Computed Properties

    var recipeCount: Int { recipes.count }
    var isEmpty: Bool { recipes.isEmpty && !isLoading }

    /// All unique tags sorted by frequency (most used first)
    var allTags: [String] {
        var tagCounts: [String: Int] = [:]
        for recipe in recipes {
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
            result.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        case .alphabetical:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .mostCooked:
            result.sort { $0.timesCooked > $1.timesCooked }
        }

        return result
    }

    private let recipeService = RecipeService.shared

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

    func startImport() {
        importURL = ""
        extractedRecipe = nil
        extractionError = nil
        isShowingImportSheet = true
    }

    func extractRecipe() async {
        guard !importURL.isEmpty else { return }

        isExtracting = true
        extractionError = nil

        do {
            extractedRecipe = try await recipeService.extractRecipe(from: importURL)
            isShowingImportSheet = false
            isShowingPreview = true
        } catch {
            extractionError = error
        }

        isExtracting = false
    }

    func saveExtractedRecipe(userId: UUID) async {
        guard let extracted = extractedRecipe else { return }

        isSaving = true

        do {
            let recipe = extracted.toRecipe(userId: userId)
            let savedRecipe = try await recipeService.saveRecipe(recipe)
            recipes.insert(savedRecipe, at: 0)
            isShowingPreview = false
            extractedRecipe = nil
            importURL = ""
        } catch {
            self.error = error
        }

        isSaving = false
    }

    func cancelImport() {
        isShowingImportSheet = false
        isShowingPreview = false
        extractedRecipe = nil
        importURL = ""
        extractionError = nil
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
