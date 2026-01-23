import Foundation

enum GroceryListServiceError: LocalizedError {
    case unauthorized
    case listNotFound
    case createFailed(String)
    case updateFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Please sign in to continue"
        case .listNotFound:
            return "Grocery list not found"
        case .createFailed(let message):
            return "Failed to create grocery list: \(message)"
        case .updateFailed(let message):
            return "Failed to update grocery list: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete grocery list: \(message)"
        }
    }
}

actor GroceryListService {
    static let shared = GroceryListService()

    private let supabase = SupabaseService.shared

    // MARK: - Fetch Grocery List

    /// Fetches the grocery list for a given menu
    func fetchGroceryList(menuId: UUID) async throws -> GroceryList? {
        guard await supabase.authUser != nil else {
            throw GroceryListServiceError.unauthorized
        }

        let lists: [GroceryList] = try await supabase.client
            .from("grocery_lists")
            .select()
            .eq("menu_id", value: menuId.uuidString)
            .limit(1)
            .execute()
            .value

        return lists.first
    }

    // MARK: - Create Grocery List

    func createGroceryList(menuId: UUID, items: [GroceryItem], staples: [String]) async throws -> GroceryList {
        guard await supabase.authUser != nil else {
            throw GroceryListServiceError.unauthorized
        }

        let newList = GroceryListInsertDTO(
            menuId: menuId,
            items: items,
            staplesConfirmed: staples
        )

        let insertedLists: [GroceryList] = try await supabase.client
            .from("grocery_lists")
            .insert(newList)
            .select()
            .execute()
            .value

        guard let list = insertedLists.first else {
            throw GroceryListServiceError.createFailed("No list returned")
        }

        return list
    }

    // MARK: - Update Item Checked Status

    func updateGroceryList(listId: UUID, items: [GroceryItem]) async throws {
        guard await supabase.authUser != nil else {
            throw GroceryListServiceError.unauthorized
        }

        try await supabase.client
            .from("grocery_lists")
            .update(["items": items])
            .eq("id", value: listId.uuidString)
            .execute()
    }

    // MARK: - Delete Grocery List

    func deleteGroceryList(_ listId: UUID) async throws {
        guard await supabase.authUser != nil else {
            throw GroceryListServiceError.unauthorized
        }

        try await supabase.client
            .from("grocery_lists")
            .delete()
            .eq("id", value: listId.uuidString)
            .execute()
    }
}

// MARK: - DTOs

private struct GroceryListInsertDTO: Encodable {
    let menuId: UUID
    let items: [GroceryItem]
    let staplesConfirmed: [String]

    enum CodingKeys: String, CodingKey {
        case menuId = "menu_id"
        case items
        case staplesConfirmed = "staples_confirmed"
    }
}
