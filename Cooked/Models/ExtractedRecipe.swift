import Foundation

// MARK: - Import Trigger Request

/// Request payload for `POST /api/recipes/import`.
struct ImportRequest: Encodable {
    let url: String
    let sourceType: String?

    enum CodingKeys: String, CodingKey {
        case url
        case sourceType = "source_type"
    }
}

// MARK: - Import Trigger Response

/// Response from `POST /api/recipes/import`.
///
/// Returns the server-created recipe ID and lightweight metadata
/// (scraped from OG/oEmbed tags) while full extraction runs in the background.
struct ImportMetadata: Decodable, Sendable {
    let recipeId: UUID
    let status: String
    let title: String
    let sourceName: String?
    let sourceUrl: String
    let imageUrl: String?
    let platform: String?

    enum CodingKeys: String, CodingKey {
        case recipeId = "recipe_id"
        case status
        case title
        case sourceName = "source_name"
        case sourceUrl = "source_url"
        case imageUrl = "image_url"
        case platform
    }
}

// MARK: - SSE Events

/// Data received from an SSE progress event.
struct ImportProgressEvent: Decodable, Sendable {
    let stage: String
    let message: String
}

/// Data received from an SSE completion event.
struct ImportCompleteEvent: Decodable, Sendable {
    let ingredients: [ExtractedIngredient]
    let steps: [String]
    let tags: [String]
}

/// Data received from an SSE error event.
struct ImportErrorEvent: Decodable, Sendable {
    let reason: String
}

// MARK: - Legacy API Request (deprecated)

/// Request payload for the recipe extraction API.
struct ExtractRequest: Encodable {
    let url: String
    let sourceType: String?

    enum CodingKeys: String, CodingKey {
        case url
        case sourceType
    }
}

// MARK: - Legacy API Response (deprecated)

/// Response from the recipe extraction API.
struct ExtractResponse: Decodable {
    let success: Bool
    let recipe: ExtractedRecipe
}

// MARK: - Extracted Recipe

/// Recipe data extracted from an external URL by the backend API.
///
/// This is a temporary data structure used during the import flow.
/// Users can preview and edit this data before converting it to a
/// ``Recipe`` and saving to the database.
///
/// ## Conversion
///
/// Use ``toRecipe(userId:)`` to convert to a saveable ``Recipe`` object.
struct ExtractedRecipe: Codable, Sendable {
    /// Extracted recipe title
    var title: String

    /// Source type (e.g., "video", "url")
    var sourceType: String

    /// Original URL the recipe was extracted from
    var sourceUrl: String

    /// Name of the source (website or content creator)
    var sourceName: String?

    /// Extracted ingredients list
    var ingredients: [ExtractedIngredient]

    /// Extracted cooking steps
    var steps: [String]

    /// Auto-generated tags based on recipe content
    var tags: [String]

    /// URL to the recipe's image
    var imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case title
        case sourceType = "source_type"
        case sourceUrl = "source_url"
        case sourceName = "source_name"
        case ingredients
        case steps
        case tags
        case imageUrl = "image_url"
    }

    /// Converts the extracted recipe to a saveable Recipe object.
    ///
    /// - Parameter userId: The ID of the user who will own this recipe
    /// - Returns: A ``Recipe`` ready to be saved to the database
    func toRecipe(userId: UUID) -> Recipe {
        Recipe(
            userId: userId,
            title: title,
            sourceType: Recipe.SourceType(rawValue: sourceType),
            sourceUrl: sourceUrl,
            sourceName: sourceName,
            ingredients: ingredients.map { $0.toIngredient() },
            steps: steps,
            tags: tags,
            imageUrl: imageUrl
        )
    }
}

// MARK: - Extracted Ingredient

/// An ingredient extracted from an external recipe source.
///
/// Contains minimal data that will be enriched when converted to ``Ingredient``.
struct ExtractedIngredient: Codable, Sendable {
    /// The ingredient description
    var text: String

    /// The quantity (may include unit, e.g., "2 cups")
    var quantity: String?

    /// Converts to a full Ingredient object.
    ///
    /// - Returns: An ``Ingredient`` with a generated UUID
    func toIngredient() -> Ingredient {
        Ingredient(text: text, quantity: quantity)
    }
}

// MARK: - API Error

/// Error response from the backend API.
struct APIError: Decodable {
    /// HTTP status code (if available)
    let statusCode: Int?

    /// Human-readable error message
    let message: String
}
