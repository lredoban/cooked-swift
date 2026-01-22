import Foundation

struct GroceryList: Codable, Identifiable, Sendable {
    let id: UUID
    let menuId: UUID
    var items: [GroceryItem]
    var staplesConfirmed: [String]
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case menuId = "menu_id"
        case items
        case staplesConfirmed = "staples_confirmed"
        case createdAt = "created_at"
    }
}

struct GroceryItem: Codable, Identifiable, Sendable, Hashable {
    var id: UUID = UUID()
    var text: String
    var quantity: String?
    var category: Ingredient.IngredientCategory
    var isChecked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case quantity
        case category
        case isChecked = "is_checked"
    }
}
