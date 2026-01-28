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

    // MARK: - Import Trigger (Backend API)

    /// Triggers a recipe import on the server.
    ///
    /// Sends the URL to `POST /api/recipes/import`. The server scrapes
    /// lightweight metadata (OG/oEmbed), creates the recipe in the database
    /// with status `importing`, and kicks off full extraction as a background job.
    ///
    /// - Parameter urlString: The URL to import from
    /// - Returns: ``ImportMetadata`` with recipe ID and preview data
    /// - Throws: ``RecipeServiceError`` if the trigger call fails
    func triggerImport(from urlString: String) async throws -> ImportMetadata {
        guard URL(string: urlString) != nil else {
            throw RecipeServiceError.invalidURL
        }

        let endpoint = AppConfig.backendURL.appendingPathComponent("api/recipes/import")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = try? await supabase.client.auth.session.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body = ImportRequest(url: urlString, sourceType: nil)
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

        return try JSONDecoder().decode(ImportMetadata.self, from: data)
    }

    /// Fetches a single recipe by ID (polling fallback for SSE).
    ///
    /// - Parameter id: The recipe ID
    /// - Returns: The recipe with current status and available data
    func fetchRecipe(id: UUID) async throws -> Recipe {
        let recipes: [Recipe] = try await supabase.client
            .from("recipes")
            .select()
            .eq("id", value: id.uuidString)
            .execute()
            .value

        guard let recipe = recipes.first else {
            throw RecipeServiceError.extractionFailed("Recipe not found")
        }
        return recipe
    }

    /// Updates a recipe in the database.
    ///
    /// - Parameter recipe: The recipe with updated fields
    /// - Returns: The updated recipe
    func updateRecipe(_ recipe: Recipe) async throws -> Recipe {
        // Only send mutable fields to avoid Supabase RLS/column conflicts
        let updatePayload = RecipeUpdate(
            title: recipe.title,
            sourceType: recipe.sourceType,
            sourceUrl: recipe.sourceUrl,
            sourceName: recipe.sourceName,
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            tags: recipe.tags,
            imageUrl: recipe.imageUrl,
            timesCooked: recipe.timesCooked,
            status: recipe.importStatus
        )

        let updated: [Recipe] = try await supabase.client
            .from("recipes")
            .update(updatePayload)
            .eq("id", value: recipe.id.uuidString)
            .select()
            .execute()
            .value

        guard let result = updated.first else {
            throw RecipeServiceError.saveFailed("No recipe returned from update")
        }
        return result
    }

    /// Partial update payload containing only mutable recipe fields.
    private struct RecipeUpdate: Encodable {
        let title: String
        let sourceType: Recipe.SourceType?
        let sourceUrl: String?
        let sourceName: String?
        let ingredients: [Ingredient]
        let steps: [String]
        let tags: [String]
        let imageUrl: String?
        let timesCooked: Int
        let status: Recipe.ImportStatus

        enum CodingKeys: String, CodingKey {
            case title
            case sourceType = "source_type"
            case sourceUrl = "source_url"
            case sourceName = "source_name"
            case ingredients
            case steps
            case tags
            case imageUrl = "image_url"
            case timesCooked = "times_cooked"
            case status
        }
    }

    // MARK: - Legacy Extraction (deprecated — use triggerImport)

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
