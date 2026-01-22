import Foundation

enum RecipeServiceError: LocalizedError {
    case extractionFailed(String)
    case networkError
    case invalidURL
    case unauthorized
    case saveFailed(String)
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

actor RecipeService {
    static let shared = RecipeService()

    private let supabase = SupabaseService.shared

    // MARK: - Recipe Extraction (Backend API)

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

    func deleteRecipe(_ recipe: Recipe) async throws {
        try await supabase.client
            .from("recipes")
            .delete()
            .eq("id", value: recipe.id.uuidString)
            .execute()
    }
}
