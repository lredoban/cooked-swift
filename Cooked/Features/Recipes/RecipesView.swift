import SwiftUI

struct RecipesView: View {
    @Environment(RecipeState.self) private var recipeState

    private let columns = [
        GridItem(.flexible(), spacing: ElectricUI.gridSpacing),
        GridItem(.flexible(), spacing: ElectricUI.gridSpacing)
    ]

    var body: some View {
        @Bindable var state = recipeState

        NavigationStack {
            Group {
                if recipeState.isLoading && recipeState.recipes.isEmpty {
                    LoadingView(message: "Loading recipes...")
                } else if recipeState.isEmpty {
                    emptyStateView
                } else {
                    recipeGridView
                }
            }
            .warmConcreteBackground()
            .navigationTitle("Recipes")
            .searchable(text: $state.searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 8) {
                        SortPicker(selection: $state.sortOption)
                        Button {
                            recipeState.startImport()
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                                .foregroundColor(.hyperOrange)
                        }
                    }
                }
            }
            .sheet(isPresented: $state.isShowingImportSheet) {
                ImportRecipeSheet()
            }
            .sheet(isPresented: $state.isShowingPreview) {
                RecipePreviewSheet()
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            // Playful icon with background
            ZStack {
                Circle()
                    .fill(Color.hyperOrange.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "book.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.hyperOrange)
            }

            Text("No Recipes Yet")
                .font(.electricDisplay)
                .foregroundColor(.ink)

            Text("Import your first recipe to get started")
                .font(.electricBody)
                .foregroundColor(.graphite)

            Button {
                recipeState.startImport()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("Import Recipe")
                }
                .electricPrimaryButton()
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)

            Spacer()
        }
    }

    private var recipeGridView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ElectricUI.gridSpacing) {
                // Tag filter bar
                if !recipeState.allTags.isEmpty {
                    TagFilterBar(
                        tags: recipeState.allTags,
                        selectedTag: recipeState.selectedTag,
                        onTagTap: { recipeState.toggleTag($0) }
                    )
                }

                // Results count
                HStack {
                    Text(resultsText)
                        .font(.electricCaption)
                        .foregroundColor(.graphite)

                    if hasActiveFilters {
                        Button("Clear") {
                            recipeState.clearFilters()
                        }
                        .font(.electricCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.hyperOrange)
                    }
                }
                .padding(.horizontal)

                // Recipe grid or no results
                if recipeState.filteredRecipes.isEmpty {
                    noResultsView
                } else {
                    LazyVGrid(columns: columns, spacing: ElectricUI.gridSpacing) {
                        ForEach(recipeState.filteredRecipes) { recipe in
                            if recipe.importStatus == .pendingReview {
                                Button {
                                    recipeState.openPendingRecipe(recipe)
                                } label: {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Rectangle())
                            } else if recipe.importStatus == .importing {
                                RecipeCard(recipe: recipe)
                                    .opacity(0.7)
                            } else {
                                NavigationLink(value: recipe) {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(.plain)
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .refreshable {
            await recipeState.loadRecipes()
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.warmConcrete)
                    .frame(width: 80, height: 80)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.graphite)
            }

            Text("No recipes found")
                .font(.electricSubheadline)
                .foregroundColor(.ink)

            Text("Try adjusting your search or filters")
                .font(.electricCaption)
                .foregroundColor(.graphite)

            Button("Clear Filters") {
                recipeState.clearFilters()
            }
            .electricSecondaryButton()
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var hasActiveFilters: Bool {
        !recipeState.searchText.isEmpty || recipeState.selectedTag != nil
    }

    private var resultsText: String {
        let filtered = recipeState.filteredRecipes.count
        let total = recipeState.recipes.count
        if hasActiveFilters {
            return "\(filtered) of \(total) recipes"
        } else {
            return "\(total) recipes"
        }
    }
}

#Preview {
    RecipesView()
        .environment(RecipeState())
        .environment(SupabaseService.shared)
        .environment(SubscriptionState())
}
