import Foundation

/// A menu represents a collection of recipes the user plans to cook.
///
/// Menus follow a state machine lifecycle:
/// ```
/// EMPTY ──[add recipe]──▶ PLANNING ──[generate list]──▶ TO COOK ──[all cooked]──▶ ARCHIVED
/// ```
///
/// Only one menu can be in the "to_cook" state at a time. Users build menus
/// during planning, then commit to cooking them. Once all recipes are marked
/// as cooked, the menu can be archived.
///
/// ## Topics
///
/// ### Menu States
/// - ``MenuStatus``
struct Menu: Codable, Identifiable, Sendable {
    /// Unique identifier for the menu
    let id: UUID

    /// ID of the user who owns this menu
    let userId: UUID

    /// Current state in the menu lifecycle
    var status: MenuStatus

    /// When the menu was created
    let createdAt: Date

    /// When the menu was archived (nil if not archived)
    var archivedAt: Date?

    /// Recipes included in this menu (without full recipe data)
    var recipes: [MenuRecipe]

    /// The lifecycle state of a menu.
    ///
    /// Menus progress through states as users plan and cook:
    /// - `planning`: User is adding/removing recipes
    /// - `toCook`: Menu is finalized, grocery list generated
    /// - `archived`: All recipes cooked, menu saved to history
    enum MenuStatus: String, Codable, Sendable {
        /// User is building the menu
        case planning
        /// Menu is active and user is cooking from it
        case toCook = "to_cook"
        /// Menu has been completed and saved to history
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

/// A recipe entry within a menu (junction table record).
///
/// This lightweight struct links a menu to a recipe and tracks
/// whether the recipe has been cooked in this menu cycle.
struct MenuRecipe: Codable, Identifiable, Sendable {
    /// Unique identifier for this menu-recipe association
    let id: UUID

    /// ID of the associated recipe
    let recipeId: UUID

    /// Whether this recipe has been marked as cooked in this menu
    var isCooked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case isCooked = "is_cooked"
    }
}

// MARK: - Menu with Full Recipe Data

/// A menu with fully populated Recipe objects for display in the UI.
///
/// This struct is used after joining `menus` with `menu_recipes` and `recipes` tables.
/// It contains complete recipe data needed for rendering, unlike ``Menu`` which
/// only contains recipe IDs.
///
/// ## Computed Properties
///
/// Provides convenient accessors for menu progress:
/// - ``cookedCount``: Number of recipes marked as cooked
/// - ``totalCount``: Total recipes in the menu
/// - ``progress``: Completion percentage (0.0 to 1.0)
/// - ``isComplete``: Whether all recipes are cooked
struct MenuWithRecipes: Identifiable, Sendable, Hashable {
    static func == (lhs: MenuWithRecipes, rhs: MenuWithRecipes) -> Bool {
        lhs.id == rhs.id &&
        lhs.status == rhs.status &&
        lhs.items == rhs.items
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(status)
        hasher.combine(items)
    }

    let id: UUID
    let userId: UUID
    var status: Menu.MenuStatus
    let createdAt: Date
    var archivedAt: Date?
    var items: [MenuItemWithRecipe]

    // MARK: - Computed Properties

    /// Number of recipes that have been marked as cooked
    var cookedCount: Int {
        items.filter(\.isCooked).count
    }

    /// Total number of recipes in the menu
    var totalCount: Int {
        items.count
    }

    /// Completion progress as a value from 0.0 to 1.0
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(cookedCount) / Double(totalCount)
    }

    /// Whether all recipes in the menu have been cooked
    var isComplete: Bool {
        cookedCount == totalCount && totalCount > 0
    }

    /// Whether the menu contains no recipes
    var isEmpty: Bool {
        items.isEmpty
    }
}

/// A recipe within a menu, including full recipe data for display.
///
/// Contains the junction table ID (for database operations) along with
/// the complete recipe object and cooking status.
struct MenuItemWithRecipe: Identifiable, Sendable, Equatable, Hashable {
    /// Junction table ID (menu_recipes.id) - used for database updates
    let id: UUID
    /// Complete recipe data for display
    let recipe: Recipe
    /// Whether this recipe has been cooked in this menu cycle
    var isCooked: Bool

    static func == (lhs: MenuItemWithRecipe, rhs: MenuItemWithRecipe) -> Bool {
        lhs.id == rhs.id && lhs.isCooked == rhs.isCooked
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isCooked)
    }
}
