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

// MARK: - Menu with Full Recipe Data

/// A menu with fully populated Recipe objects (not just IDs)
/// Used for display in the UI after joining menu_recipes with recipes table
struct MenuWithRecipes: Identifiable, Sendable, Hashable {
    static func == (lhs: MenuWithRecipes, rhs: MenuWithRecipes) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: UUID
    let userId: UUID
    var status: Menu.MenuStatus
    let createdAt: Date
    var archivedAt: Date?
    var items: [MenuItemWithRecipe]

    // MARK: - Computed Properties

    var cookedCount: Int {
        items.filter(\.isCooked).count
    }

    var totalCount: Int {
        items.count
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(cookedCount) / Double(totalCount)
    }

    var isComplete: Bool {
        cookedCount == totalCount && totalCount > 0
    }

    var isEmpty: Bool {
        items.isEmpty
    }
}

/// A single recipe within a menu, with the full Recipe data
struct MenuItemWithRecipe: Identifiable, Sendable {
    let id: UUID           // menu_recipes.id (junction table ID)
    let recipe: Recipe     // Full recipe object
    var isCooked: Bool
}
