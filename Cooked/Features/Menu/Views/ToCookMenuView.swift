import SwiftUI

struct ToCookMenuView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState
    @Environment(GroceryListState.self) private var groceryState
    @State private var showArchiveConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress Header with neon glow
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(menu.cookedCount) of \(menu.totalCount) cooked")
                            .font(.glassHeadline())
                            .foregroundColor(.glassTextPrimary)

                        Spacer()

                        Text("\(Int(menu.progress * 100))%")
                            .font(.glassMono(14))
                            .foregroundColor(.glassTextSecondary)
                    }

                    GlassProgressBar(value: menu.progress, tint: .neonGreen)
                }
                .padding(.horizontal)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Cooking progress: \(menu.cookedCount) of \(menu.totalCount) recipes cooked, \(Int(menu.progress * 100)) percent complete")

                // Generate Grocery List Button
                Button {
                    groceryState.prepareListGeneration(from: menu)
                } label: {
                    Label("Generate Grocery List", systemImage: "checklist")
                        .font(.glassHeadline())
                        .frame(maxWidth: .infinity)
                        .glassButton()
                }
                .buttonStyle(.plain)
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
                .foregroundColor(.glassTextPrimary)
        }
    }
}

struct ToCookRecipeRow: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        HStack(spacing: 12) {
            // Glass checkbox
            GlassCheckbox(isChecked: item.isCooked) {
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
                .frame(width: 60, height: 60)
                .background(Color.glassSurface)
                .cornerRadius(12)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.recipe.title)
                    .font(.glassBodyMedium(15))
                    .foregroundColor(item.isCooked ? .glassTextTertiary : .glassTextPrimary)
                    .opacity(item.isCooked ? 0.3 : 1.0) // Dim instead of strikethrough

                if let sourceName = item.recipe.sourceName {
                    Text(sourceName)
                        .font(.glassMono(11))
                        .foregroundColor(.glassTextSecondary)
                        .opacity(item.isCooked ? 0.3 : 1.0)
                }
            }

            Spacer()
        }
        .padding(16)
        .glassBackground(cornerRadius: 16)
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
        .spatialBackground()
        .navigationTitle("Menu")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    .environment(MenuState())
    .environment(GroceryListState())
}
