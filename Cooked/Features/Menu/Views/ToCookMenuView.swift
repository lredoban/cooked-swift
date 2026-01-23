import SwiftUI

struct ToCookMenuView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState
    @Environment(GroceryListState.self) private var groceryState
    @State private var showArchiveConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(menu.cookedCount) of \(menu.totalCount) cooked")
                            .font(.headline)

                        Spacer()

                        Text("\(Int(menu.progress * 100))%")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ProgressView(value: menu.progress)
                        .tint(.orange)
                }
                .padding(.horizontal)

                // Generate Grocery List Button
                Button {
                    groceryState.prepareListGeneration(from: menu)
                } label: {
                    Label("Generate Grocery List", systemImage: "checklist")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal)

                // Recipe List (as checklist)
                VStack(spacing: 12) {
                    ForEach(menu.items) { item in
                        ToCookRecipeRow(item: item)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .sheet(isPresented: Binding(
            get: { groceryState.isShowingGenerateSheet },
            set: { groceryState.isShowingGenerateSheet = $0 }
        )) {
            GenerateListSheet(menuId: menu.id)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                menuButton
            }
        }
        .confirmationDialog("Archive this menu?", isPresented: $showArchiveConfirmation) {
            Button("Archive", role: .destructive) {
                Task {
                    await menuState.archiveCurrentMenu()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can view archived menus in history.")
        }
    }

    @ViewBuilder
    private var menuButton: some View {
        SwiftUI.Menu {
            Button(role: .destructive) {
                showArchiveConfirmation = true
            } label: {
                Label("Archive Menu", systemImage: "archivebox")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

struct ToCookRecipeRow: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    if item.isCooked {
                        await menuState.unmarkRecipeCooked(item)
                    } else {
                        await menuState.markRecipeCooked(item)
                    }
                }
            } label: {
                Image(systemName: item.isCooked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isCooked ? .green : .secondary)
            }

            AsyncImageView(url: item.recipe.imageUrl)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.recipe.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .strikethrough(item.isCooked)
                    .foregroundStyle(item.isCooked ? .secondary : .primary)

                if let sourceName = item.recipe.sourceName {
                    Text(sourceName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        ToCookMenuView(
            menu: MenuWithRecipes(
                id: UUID(),
                userId: UUID(),
                status: .toCook,
                createdAt: Date(),
                archivedAt: nil,
                items: [
                    MenuItemWithRecipe(
                        id: UUID(),
                        recipe: Recipe(userId: UUID(), title: "Pasta Carbonara", sourceName: "TikTok"),
                        isCooked: true
                    ),
                    MenuItemWithRecipe(
                        id: UUID(),
                        recipe: Recipe(userId: UUID(), title: "Caesar Salad", sourceName: "Instagram"),
                        isCooked: false
                    ),
                    MenuItemWithRecipe(
                        id: UUID(),
                        recipe: Recipe(userId: UUID(), title: "Grilled Chicken", sourceName: "YouTube"),
                        isCooked: false
                    )
                ]
            )
        )
        .navigationTitle("Menu")
    }
    .environment(MenuState())
}
