import SwiftUI

struct ToCookMenuView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState
    @Environment(GroceryListState.self) private var groceryState
    @State private var showArchiveConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Progress Header - Bold Swiss style
                SwissProgressBar(value: Double(menu.cookedCount), total: Double(menu.totalCount))
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 8)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Cooking progress: \(menu.cookedCount) of \(menu.totalCount) recipes cooked, \(Int(menu.progress * 100)) percent complete")

                // Progress label
                Text("\(menu.cookedCount) OF \(menu.totalCount) COOKED")
                    .font(.swissCaption(11))
                    .fontWeight(.medium)
                    .tracking(1)
                    .foregroundStyle(BoldSwiss.black.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                SwissDivider()

                // Generate Grocery List Button
                Button {
                    groceryState.prepareListGeneration(from: menu)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "checklist")
                            .font(.system(size: 14, weight: .bold))
                        Text("GENERATE GROCERY LIST")
                    }
                    .swissSecondaryButton()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .accessibilityHint("Creates a shopping list from your menu recipes")

                SwissDivider()

                // Recipe List (as checklist)
                VStack(spacing: 0) {
                    ForEach(Array(menu.items.enumerated()), id: \.element.id) { index, item in
                        ToCookRecipeRow(item: item)

                        if index < menu.items.count - 1 {
                            SwissDivider()
                        }
                    }
                }
                .swissBorder()
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .padding(.bottom, 40)
        }
        .background(BoldSwiss.white)
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
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(BoldSwiss.black)
        }
    }
}

struct ToCookRecipeRow: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        HStack(spacing: 16) {
            // Square checkbox
            SwissCheckbox(isChecked: item.isCooked) {
                Task {
                    if item.isCooked {
                        await menuState.unmarkRecipeCooked(item)
                    } else {
                        await menuState.markRecipeCooked(item)
                    }
                }
            }
            .accessibilityLabel(item.isCooked ? "Mark \(item.recipe.title) as not cooked" : "Mark \(item.recipe.title) as cooked")

            // Recipe image - square, no border radius
            AsyncImageView(url: item.recipe.imageUrl)
                .frame(width: 56, height: 56)
                .background(BoldSwiss.black.opacity(0.05))
                .swissClip()
                .accessibilityHidden(true)

            // Recipe info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.recipe.title.uppercased())
                    .font(.swissCaption(12))
                    .fontWeight(.bold)
                    .tracking(0.5)
                    .foregroundStyle(item.isCooked ? BoldSwiss.black.opacity(BoldSwiss.dimmedOpacity) : BoldSwiss.black)
                    .lineLimit(2)

                if let sourceName = item.recipe.sourceName {
                    Text(sourceName.uppercased())
                        .font(.swissCaption(10))
                        .tracking(0.5)
                        .foregroundStyle(BoldSwiss.black.opacity(item.isCooked ? 0.2 : 0.5))
                }
            }

            Spacer()
        }
        .padding(16)
        .background(BoldSwiss.white)
        .opacity(item.isCooked ? 0.6 : 1.0)
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
        .navigationTitle("MENU")
    }
    .environment(MenuState())
    .environment(GroceryListState())
}
