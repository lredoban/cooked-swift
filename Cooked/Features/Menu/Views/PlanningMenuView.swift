import SwiftUI

struct PlanningMenuView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("\(menu.items.count) recipe\(menu.items.count == 1 ? "" : "s")")
                        .font(.curatedCaption)
                        .foregroundStyle(Color.curatedWarmGrey)

                    Spacer()

                    Button {
                        menuState.openRecipePicker()
                    } label: {
                        Label("Add", systemImage: "plus")
                            .font(.curatedSans(size: 14, weight: .medium))
                            .foregroundStyle(Color.curatedTerracotta)
                    }
                }
                .padding(.horizontal)

                // Recipe Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(menu.items) { item in
                        MenuRecipeCard(item: item)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .safeAreaInset(edge: .bottom) {
            // "Start Cooking" button
            if !menu.items.isEmpty {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.curatedBeige)
                        .frame(height: 1)

                    Button {
                        Task {
                            await menuState.startCooking()
                        }
                    } label: {
                        Text("Ready to Cook")
                            .font(.curatedSans(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.curatedTerracotta)
                            .cornerRadius(24)
                    }
                    .padding()
                }
                .background(Color.curatedOatmeal.opacity(0.95))
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
