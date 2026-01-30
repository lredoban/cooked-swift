import SwiftUI

struct RecipesView: View {
    @Environment(RecipeState.self) private var recipeState

    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        @Bindable var state = recipeState

        NavigationStack {
            Group {
                if recipeState.isLoading && recipeState.recipes.isEmpty {
                    LoadingView(message: "LOADING RECIPES...")
                } else if recipeState.isEmpty {
                    emptyStateView
                } else {
                    recipeGridView
                }
            }
            .background(BoldSwiss.white)
            .navigationTitle("RECIPES")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $state.searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        SortPicker(selection: $state.sortOption)
                        Button {
                            recipeState.startImport()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(BoldSwiss.black)
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
        VStack(spacing: 24) {
            Spacer()

            // Large graphic icon - fork/knife with thick black lines
            Image(systemName: "fork.knife")
                .font(.system(size: 80, weight: .ultraLight))
                .foregroundStyle(BoldSwiss.black)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("NO RECIPES YET")
                    .font(.swissHeader(24))
                    .swissUppercase()
                    .foregroundStyle(BoldSwiss.black)

                Text("Import your first recipe to get started")
                    .font(.swissMono(14))
                    .foregroundStyle(BoldSwiss.black.opacity(0.6))
            }

            Button {
                recipeState.startImport()
            } label: {
                Text("IMPORT RECIPE")
                    .swissPrimaryButton()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 40)
            .padding(.top, 16)

            Spacer()
        }
    }

    private var recipeGridView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Tag filter bar
                if !recipeState.allTags.isEmpty {
                    TagFilterBar(
                        tags: recipeState.allTags,
                        selectedTag: recipeState.selectedTag,
                        onTagTap: { recipeState.toggleTag($0) }
                    )
                    .padding(.vertical, 12)

                    SwissDivider()
                }

                // Results count bar
                HStack {
                    Text(resultsText.uppercased())
                        .font(.swissCaption(11))
                        .fontWeight(.medium)
                        .tracking(1)
                        .foregroundStyle(BoldSwiss.black.opacity(0.6))

                    Spacer()

                    if hasActiveFilters {
                        Button("CLEAR") {
                            recipeState.clearFilters()
                        }
                        .font(.swissCaption(11))
                        .fontWeight(.bold)
                        .tracking(1)
                        .foregroundStyle(BoldSwiss.black)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                SwissDivider()

                // Recipe grid or no results
                if recipeState.filteredRecipes.isEmpty {
                    noResultsView
                } else {
                    LazyVGrid(columns: columns, spacing: 1) {
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
                    .swissBorder()
                }
            }
        }
        .refreshable {
            await recipeState.loadRecipes()
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(BoldSwiss.black)

            Text("NO RECIPES FOUND")
                .font(.swissHeader(18))
                .swissUppercase()
                .foregroundStyle(BoldSwiss.black)

            Text("Try adjusting your search or filters")
                .font(.swissMono(12))
                .foregroundStyle(BoldSwiss.black.opacity(0.6))

            Button("CLEAR FILTERS") {
                recipeState.clearFilters()
            }
            .font(.swissCaption(12))
            .fontWeight(.bold)
            .tracking(1)
            .foregroundStyle(BoldSwiss.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .swissBorder()
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
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
