import SwiftUI

struct RecipesView: View {
    @Environment(RecipeState.self) private var recipeState

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
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
            .background(Color.dopamineBlack)
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
                                .foregroundStyle(Color.dopamineAcid)
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
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.dopaminePink)
                .dopamineGlow(color: .dopaminePink)

            Text("No Recipes Yet")
                .font(.dopamineTitle2)
                .foregroundStyle(.white)

            Text("Import your first recipe to get started")
                .font(.dopamineBody())
                .foregroundStyle(Color.dopamineSecondary)

            Button {
                recipeState.startImport()
            } label: {
                Label("Import Recipe", systemImage: "plus")
            }
            .buttonStyle(DopaminePrimaryButtonStyle())
            .padding(.horizontal, 40)
            .padding(.top, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dopamineBlack)
    }

    private var recipeGridView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
                        .font(.dopamineCaption)
                        .foregroundStyle(Color.dopamineSecondary)

                    if hasActiveFilters {
                        Button("Clear") {
                            recipeState.clearFilters()
                        }
                        .font(.dopamineCaption)
                        .foregroundStyle(Color.dopamineAcid)
                    }
                }
                .padding(.horizontal)

                // Recipe grid or no results
                if recipeState.filteredRecipes.isEmpty {
                    noResultsView
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
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
        .background(Color.dopamineBlack)
        .refreshable {
            await recipeState.loadRecipes()
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(Color.dopamineSecondary)

            Text("No recipes found")
                .font(.dopamineHeadline)
                .foregroundStyle(.white)

            Text("Try adjusting your search or filters")
                .font(.dopamineCaption)
                .foregroundStyle(Color.dopamineSecondary)

            Button("Clear Filters") {
                recipeState.clearFilters()
            }
            .buttonStyle(DopamineSecondaryButtonStyle())
            .padding(.horizontal, 60)
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
