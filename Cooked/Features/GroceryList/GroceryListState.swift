import Foundation
import Supabase

@Observable
final class GroceryListState {
    // MARK: - View State

    enum ViewState: Equatable {
        case loading
        case empty
        case active(GroceryList)
        case error(String)

        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading), (.empty, .empty):
                return true
            case (.active(let l), .active(let r)):
                return l.id == r.id
            case (.error(let l), .error(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    var viewState: ViewState = .loading

    // MARK: - Generate Sheet State

    var isShowingGenerateSheet = false
    var pendingItems: [GroceryItem] = []
    var selectedStaples: Set<String> = []
    var isGenerating = false

    // MARK: - Common Staples

    static let commonStaples = [
        "salt", "pepper", "olive oil", "butter", "garlic",
        "onion", "flour", "sugar", "vegetable oil", "eggs"
    ]

    // MARK: - Active List

    var activeList: GroceryList? {
        if case .active(let list) = viewState {
            return list
        }
        return nil
    }

    var checkedCount: Int {
        activeList?.items.filter(\.isChecked).count ?? 0
    }

    var totalCount: Int {
        activeList?.items.count ?? 0
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(checkedCount) / Double(totalCount)
    }

    private let groceryService = GroceryListService.shared
    private let supabase = SupabaseService.shared

    // MARK: - Realtime

    private var realtimeChannel: RealtimeChannelV2?
    private var realtimeTask: Task<Void, Never>?

    // MARK: - Sharing

    var isGeneratingShareLink = false
    var shareURL: URL?

    // MARK: - Load Grocery List

    func loadGroceryList(menuId: UUID) async {
        viewState = .loading

        do {
            if let list = try await groceryService.fetchGroceryList(menuId: menuId) {
                viewState = .active(list)
            } else {
                viewState = .empty
            }
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    // MARK: - Prepare List Generation

    /// Consolidates ingredients from all recipes in the menu
    func prepareListGeneration(from menu: MenuWithRecipes) {
        // Consolidate ingredients
        var ingredientMap: [String: GroceryItem] = [:]

        for item in menu.items {
            for ingredient in item.recipe.ingredients {
                let key = ingredient.text.lowercased().trimmingCharacters(in: .whitespaces)

                if var existing = ingredientMap[key] {
                    // Combine quantities
                    if let newQty = ingredient.quantity {
                        if let existingQty = existing.quantity {
                            existing.quantity = "\(existingQty), \(newQty)"
                        } else {
                            existing.quantity = newQty
                        }
                    }
                    ingredientMap[key] = existing
                } else {
                    // Add new item
                    ingredientMap[key] = GroceryItem(
                        id: UUID(),
                        text: ingredient.text,
                        quantity: ingredient.quantity,
                        category: ingredient.category ?? .other,
                        isChecked: false
                    )
                }
            }
        }

        // Sort by category then by name
        pendingItems = ingredientMap.values.sorted { lhs, rhs in
            if lhs.category.sortOrder != rhs.category.sortOrder {
                return lhs.category.sortOrder < rhs.category.sortOrder
            }
            return lhs.text.localizedCaseInsensitiveCompare(rhs.text) == .orderedAscending
        }

        // Pre-select common staples that appear in ingredients
        selectedStaples = []
        for staple in Self.commonStaples {
            if ingredientMap.keys.contains(where: { $0.contains(staple.lowercased()) }) {
                selectedStaples.insert(staple)
            }
        }

        isShowingGenerateSheet = true
    }

    // MARK: - Generate List

    func generateList(menuId: UUID) async {
        isGenerating = true

        // Remove selected staples from items
        let itemsToSave = pendingItems.filter { item in
            !selectedStaples.contains { staple in
                item.text.lowercased().contains(staple.lowercased())
            }
        }

        do {
            let list = try await groceryService.createGroceryList(
                menuId: menuId,
                items: itemsToSave,
                staples: Array(selectedStaples)
            )
            viewState = .active(list)
            isShowingGenerateSheet = false
            pendingItems = []
            selectedStaples = []
        } catch {
            viewState = .error(error.localizedDescription)
        }

        isGenerating = false
    }

    // MARK: - Toggle Item Checked

    func toggleItemChecked(_ item: GroceryItem) async {
        guard case .active(var list) = viewState else { return }

        // Find and toggle the item
        if let index = list.items.firstIndex(where: { $0.id == item.id }) {
            list.items[index].isChecked.toggle()

            // Update local state immediately for responsiveness
            viewState = .active(list)

            // Persist to database
            do {
                try await groceryService.updateGroceryList(listId: list.id, items: list.items)
            } catch {
                // Revert on error
                list.items[index].isChecked.toggle()
                viewState = .active(list)
            }
        }
    }

    // MARK: - Delete List

    func deleteList() async {
        guard let list = activeList else { return }

        do {
            try await groceryService.deleteGroceryList(list.id)
            viewState = .empty
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    // MARK: - Realtime Subscription

    /// Subscribe to realtime changes for the grocery list
    func subscribeToChanges(listId: UUID) async {
        // Unsubscribe from any existing channel first
        await unsubscribeFromChanges()

        let channel = supabase.client.channel("grocery-list-\(listId.uuidString)")

        let changes = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "grocery_lists",
            filter: .eq("id", value: listId.uuidString)
        )

        realtimeChannel = channel

        // Start listening for changes in a background task
        realtimeTask = Task { [weak self] in
            await channel.subscribe()

            for await change in changes {
                guard let self = self else { break }
                await self.handleRealtimeUpdate(change)
            }
        }
    }

    /// Unsubscribe from realtime changes
    func unsubscribeFromChanges() async {
        realtimeTask?.cancel()
        realtimeTask = nil

        if let channel = realtimeChannel {
            await channel.unsubscribe()
            realtimeChannel = nil
        }
    }

    /// Handle incoming realtime updates by refetching the list
    private func handleRealtimeUpdate(_ action: AnyAction) async {
        // Get the current list's menu ID for refetching
        guard case .active(let currentList) = await MainActor.run(body: { self.viewState }) else {
            return
        }

        switch action {
        case .update:
            // Refetch the list to get the updated data
            // This is more reliable than trying to decode the realtime payload
            do {
                if let updatedList = try await groceryService.fetchGroceryList(menuId: currentList.menuId) {
                    await MainActor.run {
                        self.viewState = .active(updatedList)
                    }
                }
            } catch {
                print("[GroceryListState] Failed to refetch list after realtime update: \(error)")
            }
        case .delete:
            await MainActor.run {
                self.viewState = .empty
            }
        default:
            break
        }
    }

    // MARK: - Share Link

    /// Generate a shareable link for the grocery list
    func generateShareLink() async {
        guard let list = activeList else { return }

        isGeneratingShareLink = true

        do {
            let token = try await groceryService.generateShareToken(listId: list.id)

            // Update local state with the new token
            var updatedList = list
            updatedList.shareToken = token
            viewState = .active(updatedList)

            // Build the share URL
            shareURL = AppConfig.backendURL.appendingPathComponent("list/\(token)")
        } catch {
            // Handle error silently for now, user can retry
            print("[GroceryListState] Failed to generate share link: \(error)")
        }

        isGeneratingShareLink = false
    }

    /// Revoke the shareable link
    func revokeShareLink() async {
        guard let list = activeList else { return }

        do {
            try await groceryService.revokeShareToken(listId: list.id)

            // Update local state
            var updatedList = list
            updatedList.shareToken = nil
            viewState = .active(updatedList)
            shareURL = nil
        } catch {
            print("[GroceryListState] Failed to revoke share link: \(error)")
        }
    }

}

// MARK: - IngredientCategory Extensions

extension Ingredient.IngredientCategory {
    var sortOrder: Int {
        switch self {
        case .produce: return 0
        case .meat: return 1
        case .seafood: return 2
        case .dairy: return 3
        case .bakery: return 4
        case .frozen: return 5
        case .pantry: return 6
        case .other: return 7
        }
    }

    var displayName: String {
        switch self {
        case .produce: return "Produce"
        case .meat: return "Meat & Poultry"
        case .seafood: return "Seafood"
        case .dairy: return "Dairy & Eggs"
        case .bakery: return "Bakery"
        case .frozen: return "Frozen"
        case .pantry: return "Pantry"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .produce: return "leaf.fill"
        case .meat: return "fork.knife"
        case .seafood: return "fish.fill"
        case .dairy: return "drop.fill"
        case .bakery: return "birthday.cake.fill"
        case .frozen: return "snowflake"
        case .pantry: return "archivebox.fill"
        case .other: return "basket.fill"
        }
    }
}
