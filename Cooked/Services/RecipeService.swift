import Foundation

/// Errors that can occur during recipe operations.
enum RecipeServiceError: LocalizedError {
    /// Recipe extraction from URL failed
    case extractionFailed(String)
    /// Network request failed
    case networkError
    /// The provided URL is malformed
    case invalidURL
    /// User is not authenticated
    case unauthorized
    /// Failed to save recipe to database
    case saveFailed(String)
    /// Failed to delete recipe from database
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .extractionFailed(let message):
            return "Failed to extract recipe: \(message)"
        case .networkError:
            return "Network connection failed"
        case .invalidURL:
            return "Invalid URL format"
        case .unauthorized:
            return "Please sign in to continue"
        case .saveFailed(let message):
            return "Failed to save recipe: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete recipe: \(message)"
        }
    }
}

/// Service for recipe extraction and CRUD operations.
///
/// This actor handles:
/// - Extracting recipes from URLs via the backend API
/// - Fetching, saving, and deleting recipes via Supabase
///
/// ## Usage
///
/// ```swift
/// let service = RecipeService.shared
///
/// // Extract from URL
/// let extracted = try await service.extractRecipe(from: "https://example.com/recipe")
///
/// // Save to database
/// let recipe = extracted.toRecipe(userId: userId)
/// let saved = try await service.saveRecipe(recipe)
/// ```
///
/// ## Thread Safety
///
/// This is an actor, so all methods are isolated and thread-safe.
actor RecipeService {
    /// Shared singleton instance
    static let shared = RecipeService()

    private let supabase = SupabaseService.shared

    // MARK: - Recipe Extraction (Backend API)

    /// Extracts recipe data from a URL using the backend API.
    ///
    /// The backend uses AI to parse recipe content from various sources
    /// including recipe websites, TikTok, Instagram, and YouTube.
    ///
    /// - Parameter urlString: The URL to extract from
    /// - Returns: Extracted recipe data ready for preview/editing
    /// - Throws: ``RecipeServiceError`` if extraction fails
    func extractRecipe(from urlString: String) async throws -> ExtractedRecipe {
        guard URL(string: urlString) != nil else {
            throw RecipeServiceError.invalidURL
        }

        let endpoint = AppConfig.backendURL.appendingPathComponent("api/recipes/extract")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ExtractRequest(url: urlString, sourceType: nil)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RecipeServiceError.networkError
        }

        if httpResponse.statusCode != 200 {
            if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                throw RecipeServiceError.extractionFailed(apiError.message)
            }
            throw RecipeServiceError.extractionFailed("Status code: \(httpResponse.statusCode)")
        }

        let result = try JSONDecoder().decode(ExtractResponse.self, from: data)
        return result.recipe
    }

    // MARK: - Recipe CRUD (Supabase)

    /// Fetches all recipes for the current user.
    ///
    /// Returns recipes sorted by creation date (newest first).
    ///
    /// - Returns: Array of user's recipes
    /// - Throws: ``RecipeServiceError/unauthorized`` if not signed in
    func fetchRecipes() async throws -> [Recipe] {
        guard let userId = await supabase.authUser?.id else {
            throw RecipeServiceError.unauthorized
        }

        return try await supabase.client
            .from("recipes")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    /// Saves a new recipe to the database.
    ///
    /// - Parameter recipe: The recipe to save
    /// - Returns: The saved recipe with any server-generated fields
    /// - Throws: ``RecipeServiceError/saveFailed(_:)`` if insert fails
    func saveRecipe(_ recipe: Recipe) async throws -> Recipe {
        let savedRecipes: [Recipe] = try await supabase.client
            .from("recipes")
            .insert(recipe)
            .select()
            .execute()
            .value

        guard let saved = savedRecipes.first else {
            throw RecipeServiceError.saveFailed("No recipe returned from insert")
        }
        return saved
    }

    /// Deletes a recipe from the database.
    ///
    /// - Parameter recipe: The recipe to delete
    /// - Throws: ``RecipeServiceError/deleteFailed(_:)`` if deletion fails
    func deleteRecipe(_ recipe: Recipe) async throws {
        try await supabase.client
            .from("recipes")
            .delete()
            .eq("id", value: recipe.id.uuidString)
            .execute()
    }
}
