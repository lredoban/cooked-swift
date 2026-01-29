import Foundation

/// An ingredient used in a recipe.
///
/// Ingredients are extracted from recipe sources and contain the item name,
/// quantity, unit of measurement, and category for grocery list organization.
///
/// ## Example
///
/// ```swift
/// let chicken = Ingredient(
///     text: "chicken breast",
///     quantity: "2",
///     unit: "lbs",
///     category: .meat
/// )
/// ```
///
/// ## Topics
///
/// ### Categories
/// - ``IngredientCategory``
struct Ingredient: Codable, Identifiable, Sendable, Hashable {
    /// Unique identifier for the ingredient
    var id: UUID

    /// The ingredient name/description (e.g., "chicken breast", "olive oil")
    var text: String

    /// Amount needed (e.g., "2", "1/2", "3-4")
    var quantity: String?

    /// Unit of measurement (e.g., "lbs", "cups", "tbsp")
    var unit: String?

    /// Category for grocery list grouping
    var category: IngredientCategory?

    /// Categories for organizing ingredients in grocery lists.
    ///
    /// Used to group items by store section for efficient shopping.
    enum IngredientCategory: String, Codable, Sendable {
        /// Fresh fruits and vegetables
        case produce
        /// Meat and poultry (chicken, beef, pork, lamb)
        case meat
        /// Fish, shrimp, shellfish
        case seafood
        /// Dairy products, eggs, and yogurt
        case dairy
        /// Shelf-stable items (canned goods, spices, oils, flour, pasta, rice)
        case pantry
        /// Frozen vegetables, fruits, ice cream
        case frozen
        /// Bread, tortillas, buns
        case bakery
        /// Items that don't fit other categories
        case other
    }

    /// Creates an ingredient by decoding from JSON.
    ///
    /// Generates a UUID if one is not present in the JSON data.
    /// - Parameter decoder: The decoder to read data from
    /// - Throws: `DecodingError` if the `text` field is missing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Generate UUID if not present in JSON
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.text = try container.decode(String.self, forKey: .text)
        self.quantity = try container.decodeIfPresent(String.self, forKey: .quantity)
        self.unit = try container.decodeIfPresent(String.self, forKey: .unit)
        self.category = try container.decodeIfPresent(IngredientCategory.self, forKey: .category)
    }

    /// Creates a new ingredient with the specified properties.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided)
    ///   - text: The ingredient name/description
    ///   - quantity: Amount needed
    ///   - unit: Unit of measurement
    ///   - category: Category for grocery list grouping
    init(id: UUID = UUID(), text: String, quantity: String? = nil, unit: String? = nil, category: IngredientCategory? = nil) {
        self.id = id
        self.text = text
        self.quantity = quantity
        self.unit = unit
        self.category = category
    }
}
