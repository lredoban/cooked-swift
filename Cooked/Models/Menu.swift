import Foundation

struct Menu: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    var status: MenuStatus
    let createdAt: Date
    var archivedAt: Date?
    var recipes: [MenuRecipe]

    enum MenuStatus: String, Codable, Sendable {
        case planning
        case toCook = "to_cook"
        case archived
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case status
        case createdAt = "created_at"
        case archivedAt = "archived_at"
        case recipes
    }
}

struct MenuRecipe: Codable, Identifiable, Sendable {
    let id: UUID
    let recipeId: UUID
    var isCooked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case isCooked = "is_cooked"
    }
}
