import SwiftUI

struct ArchivedMenuDetailView: View {
    let menu: MenuWithRecipes
    @Environment(MenuState.self) private var menuState
    @State private var isReusing = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    if let archivedAt = menu.archivedAt {
                        Text(dateFormatter.string(from: archivedAt))
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    HStack(spacing: 16) {
                        Label("\(menu.totalCount) recipes", systemImage: "fork.knife")

                        if menu.isComplete {
                            Label("All cooked", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("\(menu.cookedCount)/\(menu.totalCount) cooked", systemImage: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Cook Again Button
                Button {
                    isReusing = true
                    Task {
                        await menuState.reuseMenu(menu)
                        isReusing = false
                    }
                } label: {
                    HStack {
                        if isReusing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        Text("Cook This Again")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(isReusing || menuState.hasActiveMenu)
                .padding(.horizontal)

                if menuState.hasActiveMenu {
                    Text("You already have an active menu. Archive or complete it first.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                // Recipe List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recipes")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(menu.items) { item in
                        ArchivedRecipeRow(item: item)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Past Menu")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ArchivedRecipeRow: View {
    let item: MenuItemWithRecipe

    var body: some View {
        HStack(spacing: 12) {
            AsyncImageView(url: item.recipe.imageUrl)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.recipe.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let sourceName = item.recipe.sourceName {
                    Text(sourceName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if item.isCooked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        ArchivedMenuDetailView(
            menu: MenuWithRecipes(
                id: UUID(),
                userId: UUID(),
                status: .archived,
                createdAt: Date(),
                archivedAt: Date(),
                items: [
                    MenuItemWithRecipe(
                        id: UUID(),
                        recipe: Recipe(userId: UUID(), title: "Pasta Carbonara", sourceName: "TikTok"),
                        isCooked: true
                    ),
                    MenuItemWithRecipe(
                        id: UUID(),
                        recipe: Recipe(userId: UUID(), title: "Caesar Salad", sourceName: "Instagram"),
                        isCooked: true
                    )
                ]
            )
        )
    }
    .environment(MenuState())
}
