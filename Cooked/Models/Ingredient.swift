import Foundation

struct Ingredient: Codable, Identifiable, Sendable, Hashable {
    var id: UUID
    var text: String
    var quantity: String?
    var unit: String?
    var category: IngredientCategory?

    enum IngredientCategory: String, Codable, Sendable {
        case produce
        case meat
        case dairy
        case pantry
        case other
    }

    // Custom decoder to handle missing 'id' from database
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Generate UUID if not present in JSON
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.text = try container.decode(String.self, forKey: .text)
        self.quantity = try container.decodeIfPresent(String.self, forKey: .quantity)
        self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
        self.category = try container.decodeIfPresent(IngredientCategory.self, forKey: .category)
    }

    // Manual initializer for creating new ingredients
    init(id: UUID = UUID(), text: String, quantity: String? = nil, unit: String? = nil, category: IngredientCategory? = nil) {
        self.id = id
        self.text = text
        self.quantity = quantity
        self.unit = unit
        self.category = category
    }
}
