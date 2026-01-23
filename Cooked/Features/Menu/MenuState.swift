import Foundation

@Observable
final class MenuState {
    // MARK: - View State Enum

    enum ViewState: Equatable {
        case loading
        case empty
        case planning(MenuWithRecipes)
        case toCook(MenuWithRecipes)
        case error(String)

        static func == (lhs: ViewState, rhs: ViewState) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading), (.empty, .empty):
                return true
            case (.planning(let l), .planning(let r)):
                return l.id == r.id
            case (.toCook(let l), .toCook(let r)):
                return l.id == r.id
            case (.error(let l), .error(let r)):
                return l == r
            default:
                return false
            }
        }
    }

    // MARK: - State Properties

    var viewState: ViewState = .loading
    var isLoading = false
    var error: Error?

    // MARK: - Recipe Picker State

    var isShowingRecipePicker = false
    var selectedRecipeIds: Set<UUID> = []
    var isAddingRecipes = false

    // MARK: - History State

    var isShowingHistory = false
    var archivedMenus: [MenuWithRecipes] = []
    var isLoadingHistory = false
    var selectedArchivedMenu: MenuWithRecipes? = nil

    // MARK: - Computed Properties

    var currentMenu: MenuWithRecipes? {
        switch viewState {
        case .planning(let menu), .toCook(let menu):
            return menu
        default:
            return nil
        }
    }

    var hasActiveMenu: Bool {
        currentMenu != nil
    }

    var canStartCooking: Bool {
        guard case .planning(let menu) = viewState else { return false }
        return !menu.items.isEmpty
    }

    // MARK: - Dependencies

    private let menuService = MenuService.shared

    // MARK: - Load Menu

    func loadCurrentMenu() async {
        isLoading = true
        error = nil

        do {
            if let menu = try await menuService.fetchActiveMenu() {
                switch menu.status {
                case .planning:
                    viewState = .planning(menu)
                case .toCook:
                    viewState = .toCook(menu)
                case .archived:
                    // Archived menus shouldn't be "active", go to empty
                    viewState = .empty
                }
            } else {
                viewState = .empty
            }
        } catch {
            self.error = error
            viewState = .error(error.localizedDescription)
        }

        isLoading = false
    }

    // MARK: - Create Menu

    func createMenu() async {
        do {
            let newMenu = try await menuService.createMenu()
            viewState = .planning(newMenu)
        } catch {
            self.error = error
        }
    }

    // MARK: - Recipe Picker Actions

    func openRecipePicker() {
        // Pre-select recipes already in menu
        selectedRecipeIds = Set(currentMenu?.items.map(\.recipe.id) ?? [])
        isShowingRecipePicker = true
    }

    func closeRecipePicker() {
        isShowingRecipePicker = false
        selectedRecipeIds = []

        // If menu is empty after closing picker, delete it and return to empty state
        if case .planning(let menu) = viewState, menu.items.isEmpty {
            Task {
                do {
                    try await menuService.deleteMenu(menu.id)
                    viewState = .empty
                } catch {
                    self.error = error
                }
            }
        }
    }

    func toggleRecipeSelection(_ recipeId: UUID) {
        if selectedRecipeIds.contains(recipeId) {
            selectedRecipeIds.remove(recipeId)
        } else {
            selectedRecipeIds.insert(recipeId)
        }
    }

    func confirmRecipeSelection(availableRecipes: [Recipe]) async {
        guard case .planning(var menu) = viewState else { return }

        isAddingRecipes = true

        do {
            // Determine recipes to add and remove
            let currentIds = Set(menu.items.map(\.recipe.id))
            let toAdd = selectedRecipeIds.subtracting(currentIds)
            let toRemove = currentIds.subtracting(selectedRecipeIds)

            // Remove recipes
            for recipeId in toRemove {
                if let item = menu.items.first(where: { $0.recipe.id == recipeId }) {
                    try await menuService.removeRecipeFromMenu(menuRecipeId: item.id)
                }
            }

            // Add recipes
            for recipeId in toAdd {
                if let recipe = availableRecipes.first(where: { $0.id == recipeId }) {
                    let menuItem = try await menuService.addRecipeToMenu(
                        menuId: menu.id,
                        recipe: recipe
                    )
                    menu.items.append(menuItem)
                }
            }

            // Filter out removed items
            menu.items = menu.items.filter { selectedRecipeIds.contains($0.recipe.id) }

            // If menu is now empty, delete it
            if menu.items.isEmpty {
                try await menuService.deleteMenu(menu.id)
                viewState = .empty
            } else {
                viewState = .planning(menu)
            }

            closeRecipePicker()
        } catch {
            self.error = error
        }

        isAddingRecipes = false
    }

    // MARK: - Add Single Recipe (from RecipeDetailView)

    func addRecipeToMenu(_ recipe: Recipe) async {
        // If no menu exists, create one first
        if currentMenu == nil {
            await createMenu()
        }

        guard case .planning(var menu) = viewState else { return }

        // Check if already in menu
        guard !menu.items.contains(where: { $0.recipe.id == recipe.id }) else { return }

        do {
            let menuItem = try await menuService.addRecipeToMenu(
                menuId: menu.id,
                recipe: recipe
            )
            menu.items.append(menuItem)
            viewState = .planning(menu)
        } catch {
            self.error = error
        }
    }

    // MARK: - Remove Recipe from Menu

    func removeRecipeFromMenu(_ item: MenuItemWithRecipe) async {
        guard case .planning(var menu) = viewState else { return }

        do {
            try await menuService.removeRecipeFromMenu(menuRecipeId: item.id)
            menu.items.removeAll { $0.id == item.id }

            if menu.items.isEmpty {
                // Delete empty menu and go back to empty state
                try await menuService.deleteMenu(menu.id)
                viewState = .empty
            } else {
                viewState = .planning(menu)
            }
        } catch {
            self.error = error
        }
    }

    // MARK: - State Transitions

    func startCooking() async {
        guard case .planning(var menu) = viewState,
              !menu.items.isEmpty else { return }

        do {
            try await menuService.updateMenuStatus(menuId: menu.id, status: .toCook)
            menu.status = .toCook
            viewState = .toCook(menu)
        } catch {
            self.error = error
        }
    }

    func markRecipeCooked(_ item: MenuItemWithRecipe) async {
        guard case .toCook(var menu) = viewState else { return }

        do {
            try await menuService.markRecipeCooked(menuRecipeId: item.id, isCooked: true)

            // Update local state
            if let index = menu.items.firstIndex(where: { $0.id == item.id }) {
                menu.items[index].isCooked = true
            }

            // Check if all cooked -> auto-archive
            if menu.isComplete {
                try await menuService.archiveMenu(menu.id)
                viewState = .empty
            } else {
                viewState = .toCook(menu)
            }
        } catch {
            self.error = error
        }
    }

    func unmarkRecipeCooked(_ item: MenuItemWithRecipe) async {
        guard case .toCook(var menu) = viewState else { return }

        do {
            try await menuService.markRecipeCooked(menuRecipeId: item.id, isCooked: false)

            if let index = menu.items.firstIndex(where: { $0.id == item.id }) {
                menu.items[index].isCooked = false
            }

            viewState = .toCook(menu)
        } catch {
            self.error = error
        }
    }

    // MARK: - Archive Menu (Manual)

    func archiveCurrentMenu() async {
        guard let menu = currentMenu else { return }

        do {
            try await menuService.archiveMenu(menu.id)
            viewState = .empty
        } catch {
            self.error = error
        }
    }

    // MARK: - History Actions

    func openHistory(historyLimit: Int?) {
        isShowingHistory = true
        Task {
            await loadArchivedMenus(historyLimit: historyLimit)
        }
    }

    func closeHistory() {
        isShowingHistory = false
        selectedArchivedMenu = nil
        archivedMenus = []  // Clear to free memory
    }

    func loadArchivedMenus(historyLimit: Int?) async {
        isLoadingHistory = true

        do {
            archivedMenus = try await menuService.fetchArchivedMenus(limit: historyLimit)
        } catch {
            self.error = error
        }

        isLoadingHistory = false
    }

    func selectArchivedMenu(_ menu: MenuWithRecipes) {
        selectedArchivedMenu = menu
    }

    func reuseMenu(_ archivedMenu: MenuWithRecipes) async {
        do {
            let newMenu = try await menuService.reuseMenu(from: archivedMenu)
            viewState = .planning(newMenu)
            closeHistory()
        } catch {
            self.error = error
        }
    }
}
