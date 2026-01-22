import Foundation

@Observable
final class RecipeState {
    // MARK: - Recipe Library State

    var recipes: [Recipe] = []
    var isLoading = false
    var error: Error?

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
}
