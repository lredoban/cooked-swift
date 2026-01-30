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
                            .font(.dopamineHeadline)
                            .foregroundStyle(.white)

                        Spacer()

                        Text("\(Int(menu.progress * 100))%")
                            .font(.dopamineSubheadline)
                            .foregroundStyle(Color.dopamineSecondary)
                    }

                    ProgressView(value: menu.progress)
                        .progressViewStyle(DopamineProgressStyle())
                }
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Cooking progress: \(menu.cookedCount) of \(menu.totalCount) recipes cooked, \(Int(menu.progress * 100)) percent complete")

                // Generate Grocery List Button
                Button {
                    groceryState.prepareListGeneration(from: menu)
                } label: {
                    Label("Generate Grocery List", systemImage: "checklist")
                }
                .buttonStyle(DopaminePrimaryButtonStyle())
                .padding(.horizontal)
                .accessibilityHint("Creates a shopping list from your menu recipes")

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
        .background(Color.dopamineBlack)
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
                .foregroundStyle(Color.dopamineYellow)
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
                    .foregroundStyle(item.isCooked ? Color.dopamineAcid : Color.dopamineSecondary)
                    .dopamineGlow(color: .dopamineAcid, isActive: item.isCooked)
            }
            .accessibilityLabel(item.isCooked ? "Mark \(item.recipe.title) as not cooked" : "Mark \(item.recipe.title) as cooked")

            AsyncImageView(url: item.recipe.imageUrl)
                .frame(width: 60, height: 60)
                .background(Color.dopamineSurface)
                .cornerRadius(8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.recipe.title)
                    .font(.dopamineSubheadline)
                    .fontWeight(.medium)
                    .strikethrough(item.isCooked)
                    .foregroundStyle(item.isCooked ? Color.dopamineSecondary : .white)

                if let sourceName = item.recipe.sourceName {
                    Text(sourceName)
                        .font(.dopamineCaption)
                        .foregroundStyle(Color.dopamineSecondary)
                }
            }

            Spacer()
        }
        .padding()
        .dopamineCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(item.recipe.title), \(item.isCooked ? "cooked" : "not yet cooked")")
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
