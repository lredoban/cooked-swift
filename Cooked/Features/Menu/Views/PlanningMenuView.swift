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
                        .font(.glassMono(13))
                        .foregroundColor(.glassTextSecondary)

                    Spacer()

                    Button {
                        menuState.openRecipePicker()
                    } label: {
                        Label("Add", systemImage: "plus")
                            .font(.glassCaption(14))
                            .foregroundColor(.accentOrangeStart)
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
                        .fill(Color.glassBorder)
                        .frame(height: 1)

                    Button {
                        Task {
                            await menuState.startCooking()
                        }
                    } label: {
                        Text("Ready to Cook")
                            .font(.glassHeadline())
                            .frame(maxWidth: .infinity)
                            .glassButton()
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
                .background(Color.glassBackground.opacity(0.95))
                .background(.ultraThinMaterial)
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
        .spatialBackground()
        .navigationTitle("Menu")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    .environment(MenuState())
}
