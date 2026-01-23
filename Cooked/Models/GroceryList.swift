import Foundation

/// A shopping list generated from a menu's recipes.
///
/// Grocery lists are created when a user transitions their menu from
/// "planning" to "to_cook" status. The list consolidates all ingredients
/// from the menu's recipes, grouping them by category for efficient shopping.
///
/// ## Generation Flow
///
/// 1. User builds a menu with recipes
/// 2. User reviews staples (items they likely have)
/// 3. System generates consolidated grocery list
/// 4. User checks items off while shopping
struct GroceryList: Codable, Identifiable, Sendable {
    /// Unique identifier for the grocery list
    let id: UUID

    /// ID of the menu this list was generated from
    let menuId: UUID

    /// Consolidated items to purchase, grouped by category
    var items: [GroceryItem]

    /// Staple items the user confirmed they already have
    var staplesConfirmed: [String]

    /// When the list was generated
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case menuId = "menu_id"
        case items
        case staplesConfirmed = "staples_confirmed"
        case createdAt = "created_at"
    }
}

/// A single item on a grocery list.
///
/// Items are consolidated from recipe ingredients and include
/// the combined quantity and a checkbox for shopping.
struct GroceryItem: Codable, Identifiable, Sendable, Hashable {
    /// Unique identifier for this item
    var id: UUID = UUID()

    /// Item description (e.g., "chicken breast")
    var text: String

    /// Combined quantity needed (e.g., "3 lbs")
    var quantity: String?

    /// Category for grouping in the shopping list
    var category: Ingredient.IngredientCategory

    /// Whether the item has been purchased
    var isChecked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case quantity
        case category
        case isChecked = "is_checked"
    }
}
