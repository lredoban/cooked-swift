import Foundation

// MARK: - API Request

/// Request payload for the recipe extraction API.
///
/// Sent to `POST /api/recipes/extract` to extract recipe data from a URL.
struct ExtractRequest: Encodable {
    /// The URL to extract the recipe from
    let url: String

    /// Optional source type hint (e.g., "video", "url")
    let sourceType: String?

    enum CodingKeys: String, CodingKey {
        case url
        case sourceType
    }
}

// MARK: - API Response

/// Response from the recipe extraction API.
struct ExtractResponse: Decodable {
    /// Whether extraction was successful
    let success: Bool

    /// The extracted recipe data
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
