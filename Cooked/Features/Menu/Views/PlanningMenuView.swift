import SwiftUI

struct PlanningMenuView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState

    private let columns = [
        GridItem(.flexible(), spacing: ElectricUI.gridSpacing),
        GridItem(.flexible(), spacing: ElectricUI.gridSpacing)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ElectricUI.gridSpacing) {
                // Header
                HStack {
                    Text("\(menu.items.count) recipe\(menu.items.count == 1 ? "" : "s")")
                        .font(.electricCaption)
                        .foregroundColor(.graphite)

                    Spacer()

                    Button {
                        menuState.openRecipePicker()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add")
                        }
                        .font(.electricCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.hyperOrange)
                    }
                }
                .padding(.horizontal)

                // Recipe Grid
                LazyVGrid(columns: columns, spacing: ElectricUI.gridSpacing) {
                    ForEach(menu.items) { item in
                        MenuRecipeCard(item: item)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .warmConcreteBackground()
        .safeAreaInset(edge: .bottom) {
            // "Start Cooking" button
            if !menu.items.isEmpty {
                VStack(spacing: 0) {
                    Button {
                        Task {
                            await menuState.startCooking()
                        }
                    } label: {
                        Text("Ready to Cook")
                            .electricPrimaryButton()
                    }
                    .padding()
                }
                .background(
                    Color.surfaceWhite
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: -4)
                        .ignoresSafeArea()
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlanningMenuView(
            menu: MenuWithRecipes(
                id: UUID(),
                userId: UUID(),
                status: .planning,
                createdAt: Date(),
                archivedAt: nil,
                items: [
                    MenuItemWithRecipe(
                        id: UUID(),
                        recipe: Recipe(userId: UUID(), title: "Pasta", sourceName: "TikTok"),
                        isCooked: false
                    ),
                    MenuItemWithRecipe(
                        id: UUID(),
                        recipe: Recipe(userId: UUID(), title: "Salad", sourceName: "Instagram"),
                        isCooked: false
                    )
                ]
            )
        )
        .navigationTitle("Menu")
    }
    .environment(MenuState())
}
