import Foundation

/// Errors that can occur during menu operations.
enum MenuServiceError: LocalizedError {
    /// User is not authenticated
    case unauthorized
    /// The requested menu was not found
    case menuNotFound
    /// Failed to create a new menu
    case createFailed(String)
    /// Failed to update menu status or properties
    case updateFailed(String)
    /// Failed to delete menu
    case deleteFailed(String)
    /// Failed to add recipe to menu
    case addRecipeFailed(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Please sign in to continue"
        case .menuNotFound:
            return "Menu not found"
        case .createFailed(let message):
            return "Failed to create menu: \(message)"
        case .updateFailed(let message):
            return "Failed to update menu: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete menu: \(message)"
        case .addRecipeFailed(let message):
            return "Failed to add recipe: \(message)"
        }
    }
}

/// Service for menu CRUD operations and state management.
///
/// This actor handles all menu-related database operations including:
/// - Creating and deleting menus
/// - Adding/removing recipes from menus
/// - Transitioning menu status (planning → to_cook → archived)
/// - Fetching active and archived menus
///
/// ## Menu State Machine
///
/// ```
/// EMPTY ──[add recipe]──▶ PLANNING ──[generate list]──▶ TO COOK ──[all cooked]──▶ ARCHIVED
/// ```
///
/// ## Thread Safety
///
/// This is an actor, so all methods are isolated and thread-safe.
actor MenuService {
    /// Shared singleton instance
    static let shared = MenuService()

    private let supabase = SupabaseService.shared

    // MARK: - Fetch Active Menu

    /// Fetches the current active menu (planning or to_cook) with full recipe data
    /// Returns nil if no active menu exists
    func fetchActiveMenu() async throws -> MenuWithRecipes? {
        guard let userId = await supabase.authUser?.id else {
            throw MenuServiceError.unauthorized
        }

        // Nested select to get menu_recipes with their associated recipes
        let query = """
        id, user_id, status, created_at, archived_at,
        menu_recipes (id, recipe_id, is_cooked, recipes (*))
        """

        let menus: [MenuWithRecipesDTO] = try await supabase.client
            .from("menus")
            .select(query)
            .eq("user_id", value: userId.uuidString)
            .in("status", values: ["planning", "to_cook"])
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value

        guard let menuDTO = menus.first else {
            return nil
        }

        return menuDTO.toMenuWithRecipes()
    }

    // MARK: - Create Menu

    func createMenu() async throws -> MenuWithRecipes {
        guard let userId = await supabase.authUser?.id else {
            throw MenuServiceError.unauthorized
        }

        let newMenu = MenuInsertDTO(
            userId: userId,
            status: .planning
        )

        let insertedMenus: [MenuResponseDTO] = try await supabase.client
            .from("menus")
            .insert(newMenu)
            .select()
            .execute()
            .value

        guard let menu = insertedMenus.first else {
            throw MenuServiceError.createFailed("No menu returned")
        }

        return MenuWithRecipes(
            id: menu.id,
            userId: menu.userId,
            status: menu.status,
            createdAt: menu.createdAt,
            archivedAt: menu.archivedAt,
            items: []
        )
    }

    // MARK: - Add Recipe to Menu

    func addRecipeToMenu(menuId: UUID, recipe: Recipe) async throws -> MenuItemWithRecipe {
        let menuRecipe = MenuRecipeInsertDTO(
            menuId: menuId,
            recipeId: recipe.id,
            isCooked: false
        )

        let insertedItems: [MenuRecipeResponseDTO] = try await supabase.client
            .from("menu_recipes")
            .insert(menuRecipe)
            .select()
            .execute()
            .value

        guard let item = insertedItems.first else {
            throw MenuServiceError.addRecipeFailed("No item returned")
        }

        return MenuItemWithRecipe(
            id: item.id,
            recipe: recipe,
            isCooked: item.isCooked
        )
    }

    // MARK: - Remove Recipe from Menu

    func removeRecipeFromMenu(menuRecipeId: UUID) async throws {
        try await supabase.client
            .from("menu_recipes")
            .delete()
            .eq("id", value: menuRecipeId.uuidString)
            .execute()
    }

    // MARK: - Update Menu Status

    func updateMenuStatus(menuId: UUID, status: Menu.MenuStatus) async throws {
        try await supabase.client
            .from("menus")
            .update(["status": status.rawValue])
            .eq("id", value: menuId.uuidString)
            .execute()
    }

    // MARK: - Mark Recipe Cooked

    func markRecipeCooked(menuRecipeId: UUID, isCooked: Bool) async throws {
        try await supabase.client
            .from("menu_recipes")
            .update(["is_cooked": isCooked])
            .eq("id", value: menuRecipeId.uuidString)
            .execute()
    }

    // MARK: - Archive Menu

    func archiveMenu(_ menuId: UUID) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        try await supabase.client
            .from("menus")
            .update([
                "status": Menu.MenuStatus.archived.rawValue,
                "archived_at": formatter.string(from: Date())
            ])
            .eq("id", value: menuId.uuidString)
            .execute()
    }

    // MARK: - Delete Menu

    func deleteMenu(_ menuId: UUID) async throws {
        // menu_recipes will be cascade deleted due to FK constraint
        try await supabase.client
            .from("menus")
            .delete()
            .eq("id", value: menuId.uuidString)
            .execute()
    }

    // MARK: - Fetch Archived Menus

    /// Fetches archived menus for history view
    /// - Parameter limit: Optional limit for free tier (nil for unlimited)
    func fetchArchivedMenus(limit: Int? = nil) async throws -> [MenuWithRecipes] {
        guard let userId = await supabase.authUser?.id else {
            throw MenuServiceError.unauthorized
        }

        let query = """
        id, user_id, status, created_at, archived_at,
        menu_recipes (id, recipe_id, is_cooked, recipes (*))
        """

        var request = supabase.client
            .from("menus")
            .select(query)
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "archived")
            .order("archived_at", ascending: false)

        if let limit = limit {
            request = request.limit(limit)
        }

        let menus: [MenuWithRecipesDTO] = try await request
            .execute()
            .value

        return menus.map { $0.toMenuWithRecipes() }
    }

    // MARK: - Reuse Menu

    /// Creates a new planning menu from an archived menu's recipes
    func reuseMenu(from archivedMenu: MenuWithRecipes) async throws -> MenuWithRecipes {
        // Create new menu
        var newMenu = try await createMenu()

        // Add all recipes from archived menu
        for item in archivedMenu.items {
            let newItem = try await addRecipeToMenu(menuId: newMenu.id, recipe: item.recipe)
            newMenu.items.append(newItem)
        }

        return newMenu
    }
}

// MARK: - DTOs for Supabase Operations

private struct MenuInsertDTO: Encodable {
    let userId: UUID
    let status: Menu.MenuStatus

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case status
    }
}

private struct MenuRecipeInsertDTO: Encodable {
    let menuId: UUID
    let recipeId: UUID
    let isCooked: Bool

    enum CodingKeys: String, CodingKey {
        case menuId = "menu_id"
        case recipeId = "recipe_id"
        case isCooked = "is_cooked"
    }
}

private struct MenuResponseDTO: Decodable {
    let id: UUID
    let userId: UUID
    let status: Menu.MenuStatus
    let createdAt: Date
    let archivedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case status
        case createdAt = "created_at"
        case archivedAt = "archived_at"
    }
}

private struct MenuRecipeResponseDTO: Decodable {
    let id: UUID
    let recipeId: UUID
    let isCooked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case isCooked = "is_cooked"
    }
}

// MARK: - DTO for Nested Query Response

private struct MenuWithRecipesDTO: Decodable {
    let id: UUID
    let userId: UUID
    let status: Menu.MenuStatus
    let createdAt: Date
    let archivedAt: Date?
    let menuRecipes: [MenuRecipeWithRecipeDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case status
        case createdAt = "created_at"
        case archivedAt = "archived_at"
        case menuRecipes = "menu_recipes"
    }

    func toMenuWithRecipes() -> MenuWithRecipes {
        MenuWithRecipes(
            id: id,
            userId: userId,
            status: status,
            createdAt: createdAt,
            archivedAt: archivedAt,
            items: menuRecipes.compactMap { $0.toMenuItemWithRecipe() }
        )
    }
}

private struct MenuRecipeWithRecipeDTO: Decodable {
    let id: UUID
    let recipeId: UUID
    let isCooked: Bool
    let recipes: Recipe  // Supabase returns nested object, not array

    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case isCooked = "is_cooked"
        case recipes
    }

    func toMenuItemWithRecipe() -> MenuItemWithRecipe {
        MenuItemWithRecipe(
            id: id,
            recipe: recipes,
            isCooked: isCooked
        )
    }
}
