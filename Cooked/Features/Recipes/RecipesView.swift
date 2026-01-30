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
            .spatialBackground()
            .navigationTitle("Recipes")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.glassBackground.opacity(0.9), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $state.searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 8) {
                        SortPicker(selection: $state.sortOption)
                        Button {
                            recipeState.startImport()
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.glassTextPrimary)
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
        .preferredColorScheme(.dark)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            // Glowing icon
            ZStack {
                Circle()
                    .fill(LinearGradient.holographicOrange.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: "book.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(LinearGradient.holographicOrange)
            }
            .accessibilityHidden(true)

            Text("No Recipes Yet")
                .font(.glassTitle())
                .foregroundColor(.glassTextPrimary)

            Text("Import your first recipe to get started")
                .font(.glassBody())
                .foregroundColor(.glassTextSecondary)

            Button {
                recipeState.startImport()
            } label: {
                Label("Import Recipe", systemImage: "plus")
                    .font(.glassHeadline())
                    .glassButton()
            }
            .buttonStyle(.plain)
            .padding(.top, 8)

            Spacer()
        }
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
                        .font(.glassCaption())
                        .foregroundColor(.glassTextSecondary)

                    if hasActiveFilters {
                        Button("Clear") {
                            recipeState.clearFilters()
                        }
                        .font(.glassCaption())
                        .foregroundColor(.accentOrangeStart)
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
        .refreshable {
            await recipeState.loadRecipes()
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.glassTextSecondary)

            Text("No recipes found")
                .font(.glassHeadline())
                .foregroundColor(.glassTextPrimary)

            Text("Try adjusting your search or filters")
                .font(.glassBody())
                .foregroundColor(.glassTextSecondary)

            Button("Clear Filters") {
                recipeState.clearFilters()
            }
            .font(.glassBody())
            .glassButtonSecondary(small: true)
            .buttonStyle(.plain)
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
