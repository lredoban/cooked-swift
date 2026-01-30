import SwiftUI

struct ToCookMenuView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState
    @Environment(GroceryListState.self) private var groceryState
    @State private var showArchiveConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ElectricUI.sectionSpacing) {
                // Progress Header with Health Bar
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(menu.cookedCount) of \(menu.totalCount) cooked")
                            .font(.electricSubheadline)
                            .foregroundColor(.ink)

                        Spacer()
                    }

                    ElectricProgressBar(progress: menu.progress, showPercentage: true)
                }
                .padding()
                .background(Color.surfaceWhite)
                .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
                .shadow(
                    color: .black.opacity(ElectricUI.cardShadowOpacity),
                    radius: ElectricUI.cardShadowRadius,
                    x: 0,
                    y: ElectricUI.cardShadowY
                )
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Cooking progress: \(menu.cookedCount) of \(menu.totalCount) recipes cooked, \(Int(menu.progress * 100)) percent complete")

                // Generate Grocery List Button
                Button {
                    groceryState.prepareListGeneration(from: menu)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                        Text("Generate Grocery List")
                    }
                    .electricPrimaryButton()
                }
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
        .warmConcreteBackground()
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
                .foregroundColor(.hyperOrange)
        }
    }
}

struct ToCookRecipeRow: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        HStack(spacing: 16) {
            // Large checkbox
            ElectricCheckbox(isChecked: item.isCooked) {
                Task {
                    if item.isCooked {
                        await menuState.unmarkRecipeCooked(item)
                    } else {
                        await menuState.markRecipeCooked(item)
                    }
                }
            }
            .accessibilityLabel(item.isCooked ? "Mark \(item.recipe.title) as not cooked" : "Mark \(item.recipe.title) as cooked")

            AsyncImageView(url: item.recipe.imageUrl)
                .frame(width: 64, height: 64)
                .background(Color.warmConcrete)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.recipe.title)
                    .font(.electricSubheadline)
                    .strikethrough(item.isCooked)
                    .foregroundColor(item.isCooked ? .graphite : .ink)

                if let sourceName = item.recipe.sourceName {
                    Text(sourceName)
                        .font(.electricCaption)
                        .foregroundColor(.graphite)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.surfaceWhite)
        .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
        .shadow(
            color: .black.opacity(ElectricUI.cardShadowOpacity),
            radius: ElectricUI.cardShadowRadius,
            x: 0,
            y: ElectricUI.cardShadowY
        )
        .opacity(item.isCooked ? 0.7 : 1.0)
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
    .environment(GroceryListState())
}
