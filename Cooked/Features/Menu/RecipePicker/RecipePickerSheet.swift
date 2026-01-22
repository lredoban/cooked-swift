import SwiftUI

struct RecipePickerSheet: View {
    @Environment(MenuState.self) private var menuState
    @Environment(RecipeState.self) private var recipeState

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if recipeState.recipes.isEmpty {
                    emptyState
                } else {
                    recipeGrid
                }
            }
            .navigationTitle("Add Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        menuState.closeRecipePicker()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            await menuState.confirmRecipeSelection(
                                availableRecipes: recipeState.recipes
                            )
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(menuState.selectedRecipeIds.isEmpty || menuState.isAddingRecipes)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "book")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Recipes Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Import some recipes first to add them to your menu")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }

    private var recipeGrid: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(menuState.selectedRecipeIds.count) selected")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(recipeState.recipes) { recipe in
                        SelectableRecipeCard(
                            recipe: recipe,
                            isSelected: menuState.selectedRecipeIds.contains(recipe.id)
                        ) {
                            menuState.toggleRecipeSelection(recipe.id)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
    }
}

#Preview {
    RecipePickerSheet()
        .environment(MenuState())
        .environment(RecipeState())
}
