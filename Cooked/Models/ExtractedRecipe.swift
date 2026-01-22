import Foundation

// MARK: - API Request

struct ExtractRequest: Encodable {
    let url: String
    let sourceType: String?

    enum CodingKeys: String, CodingKey {
        case url
        case sourceType
    }
}

// MARK: - API Response

struct ExtractResponse: Decodable {
    let success: Bool
    let recipe: ExtractedRecipe
}

// MARK: - Extracted Recipe

struct ExtractedRecipe: Codable, Sendable {
    var title: String
    var sourceType: String
    var sourceUrl: String
    var sourceName: String?
    var ingredients: [ExtractedIngredient]
    var steps: [String]
    var tags: [String]
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

struct ExtractedIngredient: Codable, Sendable {
    var text: String
    var quantity: String?

    func toIngredient() -> Ingredient {
        Ingredient(text: text, quantity: quantity)
    }
}

// MARK: - API Error

struct APIError: Decodable {
    let statusCode: Int?
    let message: String
}
