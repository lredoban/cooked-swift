//
//  CookedTests.swift
//  CookedTests
//
//  Created by Lova on 22/01/2026.
//

import Testing
import Foundation
@testable import Cooked

// MARK: - Recipe Tests

struct RecipeTests {

    @Test("Recipe initializes with default values")
    func recipeInitializesWithDefaults() {
        let userId = UUID()
        let recipe = Recipe(
            userId: userId,
            title: "Test Recipe"
        )

        #expect(recipe.title == "Test Recipe")
        #expect(recipe.userId == userId)
        #expect(recipe.ingredients.isEmpty)
        #expect(recipe.steps.isEmpty)
        #expect(recipe.tags.isEmpty)
        #expect(recipe.timesCooked == 0)
        #expect(recipe.sourceType == nil)
        #expect(recipe.sourceUrl == nil)
    }

    @Test("Recipe initializes with all properties")
    func recipeInitializesWithAllProperties() {
        let userId = UUID()
        let recipeId = UUID()
        let ingredients = [
            Ingredient(text: "chicken", quantity: "2 lbs"),
            Ingredient(text: "salt", quantity: "1 tsp")
        ]
        let steps = ["Step 1", "Step 2"]
        let tags = ["dinner", "quick"]

        let recipe = Recipe(
            id: recipeId,
            userId: userId,
            title: "Chicken Dinner",
            sourceType: .url,
            sourceUrl: "https://example.com/recipe",
            sourceName: "Example Blog",
            ingredients: ingredients,
            steps: steps,
            tags: tags,
            imageUrl: "https://example.com/image.jpg",
            timesCooked: 5
        )

        #expect(recipe.id == recipeId)
        #expect(recipe.title == "Chicken Dinner")
        #expect(recipe.sourceType == .url)
        #expect(recipe.sourceUrl == "https://example.com/recipe")
        #expect(recipe.sourceName == "Example Blog")
        #expect(recipe.ingredients.count == 2)
        #expect(recipe.steps.count == 2)
        #expect(recipe.tags.count == 2)
        #expect(recipe.timesCooked == 5)
    }

    @Test("Recipe equality is based on ID")
    func recipeEqualityBasedOnId() {
        let userId = UUID()
        let recipeId = UUID()

        let recipe1 = Recipe(id: recipeId, userId: userId, title: "Recipe 1")
        let recipe2 = Recipe(id: recipeId, userId: userId, title: "Recipe 2")
        let recipe3 = Recipe(userId: userId, title: "Recipe 3")

        #expect(recipe1 == recipe2)
        #expect(recipe1 != recipe3)
    }

    @Test("Recipe SourceType raw values match database")
    func recipeSourceTypeRawValues() {
        #expect(Recipe.SourceType.video.rawValue == "video")
        #expect(Recipe.SourceType.url.rawValue == "url")
        #expect(Recipe.SourceType.manual.rawValue == "manual")
    }

    @Test("Recipe decodes from JSON with missing optional fields")
    func recipeDecodesWithMissingFields() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "user_id": "550e8400-e29b-41d4-a716-446655440001",
            "title": "Simple Recipe",
            "created_at": "2024-01-15T10:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let recipe = try decoder.decode(Recipe.self, from: Data(json.utf8))

        #expect(recipe.title == "Simple Recipe")
        #expect(recipe.ingredients.isEmpty)
        #expect(recipe.steps.isEmpty)
        #expect(recipe.tags.isEmpty)
        #expect(recipe.timesCooked == 0)
        #expect(recipe.sourceType == nil)
    }

    @Test("Recipe decodes from complete JSON")
    func recipeDecodesFromCompleteJSON() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "user_id": "550e8400-e29b-41d4-a716-446655440001",
            "title": "Full Recipe",
            "source_type": "url",
            "source_url": "https://example.com",
            "source_name": "Example",
            "ingredients": [{"text": "flour", "quantity": "2 cups"}],
            "steps": ["Mix ingredients", "Bake"],
            "tags": ["baking", "easy"],
            "image_url": "https://example.com/img.jpg",
            "created_at": "2024-01-15T10:30:00Z",
            "times_cooked": 3
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let recipe = try decoder.decode(Recipe.self, from: Data(json.utf8))

        #expect(recipe.title == "Full Recipe")
        #expect(recipe.sourceType == .url)
        #expect(recipe.ingredients.count == 1)
        #expect(recipe.steps.count == 2)
        #expect(recipe.timesCooked == 3)
    }
}

// MARK: - Ingredient Tests

struct IngredientTests {

    @Test("Ingredient initializes with text only")
    func ingredientInitializesWithTextOnly() {
        let ingredient = Ingredient(text: "olive oil")

        #expect(ingredient.text == "olive oil")
        #expect(ingredient.quantity == nil)
        #expect(ingredient.unit == nil)
        #expect(ingredient.category == nil)
    }

    @Test("Ingredient initializes with all properties")
    func ingredientInitializesWithAllProperties() {
        let id = UUID()
        let ingredient = Ingredient(
            id: id,
            text: "chicken breast",
            quantity: "2",
            unit: "lbs",
            category: .meat
        )

        #expect(ingredient.id == id)
        #expect(ingredient.text == "chicken breast")
        #expect(ingredient.quantity == "2")
        #expect(ingredient.unit == "lbs")
        #expect(ingredient.category == .meat)
    }

    @Test("Ingredient categories have correct raw values")
    func ingredientCategoriesRawValues() {
        #expect(Ingredient.IngredientCategory.produce.rawValue == "produce")
        #expect(Ingredient.IngredientCategory.meat.rawValue == "meat")
        #expect(Ingredient.IngredientCategory.dairy.rawValue == "dairy")
        #expect(Ingredient.IngredientCategory.pantry.rawValue == "pantry")
        #expect(Ingredient.IngredientCategory.other.rawValue == "other")
    }

    @Test("Ingredient decodes from JSON without ID")
    func ingredientDecodesWithoutId() throws {
        let json = """
        {
            "text": "sugar",
            "quantity": "1 cup"
        }
        """

        let ingredient = try JSONDecoder().decode(Ingredient.self, from: Data(json.utf8))

        #expect(ingredient.text == "sugar")
        #expect(ingredient.quantity == "1 cup")
        #expect(ingredient.id != UUID()) // Should have generated an ID
    }

    @Test("Ingredient decodes from complete JSON")
    func ingredientDecodesFromCompleteJSON() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "text": "milk",
            "quantity": "2",
            "unit": "cups",
            "category": "dairy"
        }
        """

        let ingredient = try JSONDecoder().decode(Ingredient.self, from: Data(json.utf8))

        #expect(ingredient.text == "milk")
        #expect(ingredient.quantity == "2")
        #expect(ingredient.unit == "cups")
        #expect(ingredient.category == .dairy)
    }

    @Test("Ingredient is hashable")
    func ingredientIsHashable() {
        let id = UUID()
        let ingredient1 = Ingredient(id: id, text: "salt")
        let ingredient2 = Ingredient(id: id, text: "salt")

        var set = Set<Ingredient>()
        set.insert(ingredient1)
        set.insert(ingredient2)

        #expect(set.count == 1)
    }
}

// MARK: - Menu Tests

struct MenuTests {

    @Test("MenuStatus raw values match database")
    func menuStatusRawValues() {
        #expect(Menu.MenuStatus.planning.rawValue == "planning")
        #expect(Menu.MenuStatus.toCook.rawValue == "to_cook")
        #expect(Menu.MenuStatus.archived.rawValue == "archived")
    }

    @Test("MenuWithRecipes computes cookedCount correctly")
    func menuWithRecipesComputesCookedCount() {
        let recipe1 = Recipe(userId: UUID(), title: "Recipe 1")
        let recipe2 = Recipe(userId: UUID(), title: "Recipe 2")
        let recipe3 = Recipe(userId: UUID(), title: "Recipe 3")

        let menu = MenuWithRecipes(
            id: UUID(),
            userId: UUID(),
            status: .toCook,
            createdAt: Date(),
            archivedAt: nil,
            items: [
                MenuItemWithRecipe(id: UUID(), recipe: recipe1, isCooked: true),
                MenuItemWithRecipe(id: UUID(), recipe: recipe2, isCooked: false),
                MenuItemWithRecipe(id: UUID(), recipe: recipe3, isCooked: true)
            ]
        )

        #expect(menu.cookedCount == 2)
        #expect(menu.totalCount == 3)
    }

    @Test("MenuWithRecipes computes progress correctly")
    func menuWithRecipesComputesProgress() {
        let recipe1 = Recipe(userId: UUID(), title: "Recipe 1")
        let recipe2 = Recipe(userId: UUID(), title: "Recipe 2")

        let menu = MenuWithRecipes(
            id: UUID(),
            userId: UUID(),
            status: .toCook,
            createdAt: Date(),
            archivedAt: nil,
            items: [
                MenuItemWithRecipe(id: UUID(), recipe: recipe1, isCooked: true),
                MenuItemWithRecipe(id: UUID(), recipe: recipe2, isCooked: false)
            ]
        )

        #expect(menu.progress == 0.5)
    }

    @Test("MenuWithRecipes progress is zero when empty")
    func menuWithRecipesProgressZeroWhenEmpty() {
        let menu = MenuWithRecipes(
            id: UUID(),
            userId: UUID(),
            status: .planning,
            createdAt: Date(),
            archivedAt: nil,
            items: []
        )

        #expect(menu.progress == 0)
        #expect(menu.isEmpty)
    }

    @Test("MenuWithRecipes isComplete when all cooked")
    func menuWithRecipesIsCompleteWhenAllCooked() {
        let recipe1 = Recipe(userId: UUID(), title: "Recipe 1")
        let recipe2 = Recipe(userId: UUID(), title: "Recipe 2")

        let completeMenu = MenuWithRecipes(
            id: UUID(),
            userId: UUID(),
            status: .toCook,
            createdAt: Date(),
            archivedAt: nil,
            items: [
                MenuItemWithRecipe(id: UUID(), recipe: recipe1, isCooked: true),
                MenuItemWithRecipe(id: UUID(), recipe: recipe2, isCooked: true)
            ]
        )

        let incompleteMenu = MenuWithRecipes(
            id: UUID(),
            userId: UUID(),
            status: .toCook,
            createdAt: Date(),
            archivedAt: nil,
            items: [
                MenuItemWithRecipe(id: UUID(), recipe: recipe1, isCooked: true),
                MenuItemWithRecipe(id: UUID(), recipe: recipe2, isCooked: false)
            ]
        )

        #expect(completeMenu.isComplete)
        #expect(!incompleteMenu.isComplete)
    }

    @Test("Empty menu is not complete")
    func emptyMenuIsNotComplete() {
        let menu = MenuWithRecipes(
            id: UUID(),
            userId: UUID(),
            status: .planning,
            createdAt: Date(),
            archivedAt: nil,
            items: []
        )

        #expect(!menu.isComplete)
        #expect(menu.isEmpty)
    }

    @Test("MenuItemWithRecipe equality based on ID and isCooked")
    func menuItemWithRecipeEquality() {
        let id = UUID()
        let recipe = Recipe(userId: UUID(), title: "Recipe")

        let item1 = MenuItemWithRecipe(id: id, recipe: recipe, isCooked: false)
        let item2 = MenuItemWithRecipe(id: id, recipe: recipe, isCooked: false)
        let item3 = MenuItemWithRecipe(id: id, recipe: recipe, isCooked: true)

        #expect(item1 == item2)
        #expect(item1 != item3)
    }
}

// MARK: - GroceryList Tests

struct GroceryListTests {

    @Test("GroceryItem initializes correctly")
    func groceryItemInitializes() {
        let item = GroceryItem(
            text: "Milk",
            quantity: "1 gallon",
            category: .dairy,
            isChecked: false
        )

        #expect(item.text == "Milk")
        #expect(item.quantity == "1 gallon")
        #expect(item.category == .dairy)
        #expect(!item.isChecked)
    }

    @Test("GroceryItem is hashable")
    func groceryItemIsHashable() {
        let id = UUID()
        let item1 = GroceryItem(id: id, text: "eggs", quantity: "12", category: .dairy, isChecked: false)
        let item2 = GroceryItem(id: id, text: "eggs", quantity: "12", category: .dairy, isChecked: false)

        var set = Set<GroceryItem>()
        set.insert(item1)
        set.insert(item2)

        #expect(set.count == 1)
    }
}

// MARK: - ExtractedRecipe Tests

struct ExtractedRecipeTests {

    @Test("ExtractedRecipe converts to Recipe correctly")
    func extractedRecipeConvertsToRecipe() {
        let userId = UUID()
        let extracted = ExtractedRecipe(
            title: "Pasta Dish",
            sourceType: "url",
            sourceUrl: "https://example.com/pasta",
            sourceName: "Food Blog",
            ingredients: [
                ExtractedIngredient(text: "pasta", quantity: "1 lb"),
                ExtractedIngredient(text: "tomato sauce", quantity: "2 cups")
            ],
            steps: ["Boil pasta", "Add sauce"],
            tags: ["italian", "easy"],
            imageUrl: "https://example.com/pasta.jpg"
        )

        let recipe = extracted.toRecipe(userId: userId)

        #expect(recipe.userId == userId)
        #expect(recipe.title == "Pasta Dish")
        #expect(recipe.sourceType == .url)
        #expect(recipe.sourceUrl == "https://example.com/pasta")
        #expect(recipe.sourceName == "Food Blog")
        #expect(recipe.ingredients.count == 2)
        #expect(recipe.ingredients[0].text == "pasta")
        #expect(recipe.steps.count == 2)
        #expect(recipe.tags == ["italian", "easy"])
    }

    @Test("ExtractedIngredient converts to Ingredient")
    func extractedIngredientConvertsToIngredient() {
        let extracted = ExtractedIngredient(text: "butter", quantity: "2 tbsp")

        let ingredient = extracted.toIngredient()

        #expect(ingredient.text == "butter")
        #expect(ingredient.quantity == "2 tbsp")
    }

    @Test("ExtractResponse decodes correctly")
    func extractResponseDecodes() throws {
        let json = """
        {
            "success": true,
            "recipe": {
                "title": "Test",
                "source_type": "url",
                "source_url": "https://test.com",
                "ingredients": [],
                "steps": [],
                "tags": []
            }
        }
        """

        let response = try JSONDecoder().decode(ExtractResponse.self, from: Data(json.utf8))

        #expect(response.success)
        #expect(response.recipe.title == "Test")
    }

    @Test("APIError decodes correctly")
    func apiErrorDecodes() throws {
        let json = """
        {
            "statusCode": 400,
            "message": "Invalid URL"
        }
        """

        let error = try JSONDecoder().decode(APIError.self, from: Data(json.utf8))

        #expect(error.statusCode == 400)
        #expect(error.message == "Invalid URL")
    }
}
