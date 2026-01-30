import SwiftUI

struct PlanningMenuView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState

    private let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header bar
                HStack {
                    Text("\(menu.items.count) RECIPE\(menu.items.count == 1 ? "" : "S")")
                        .font(.swissCaption(11))
                        .fontWeight(.medium)
                        .tracking(1)
                        .foregroundStyle(BoldSwiss.black.opacity(0.6))

                    Spacer()

                    Button {
                        menuState.openRecipePicker()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("ADD")
                                .font(.swissCaption(11))
                                .fontWeight(.bold)
                                .tracking(1)
                        }
                        .foregroundStyle(BoldSwiss.black)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                SwissDivider()

                // Recipe Grid
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(menu.items) { item in
                        MenuRecipeCard(item: item)
                    }
                }
                .swissBorder()
                .padding(.top, 16)
                .padding(.horizontal, 16)
            }
        }
        .background(BoldSwiss.white)
        .safeAreaInset(edge: .bottom) {
            // "Start Cooking" button
            if !menu.items.isEmpty {
                VStack(spacing: 0) {
                    SwissDivider()
                    Button {
                        Task {
                            await menuState.startCooking()
                        }
                    } label: {
                        Text("READY TO COOK")
                            .swissPrimaryButton()
                    }
                    .buttonStyle(.plain)
                    .padding(16)
                }
                .background(BoldSwiss.white)
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
        .navigationTitle("MENU")
    }
    .environment(MenuState())
}
