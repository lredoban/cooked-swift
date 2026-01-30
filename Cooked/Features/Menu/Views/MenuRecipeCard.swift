import SwiftUI

struct MenuRecipeCard: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        FrostedImageCard(imageUrl: item.recipe.imageUrl, height: 160) {
            Text(item.recipe.title)
                .font(.glassBodyMedium(14))
                .foregroundColor(.glassTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                Task {
                    await menuState.removeRecipeFromMenu(item)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.glassTextPrimary)
                    .background(
                        Circle()
                            .fill(Color.glassBackground.opacity(0.6))
                            .padding(2)
                    )
            }
            .padding(8)
            .accessibilityLabel("Remove \(item.recipe.title) from menu")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(item.recipe.title)
        .accessibilityHint(item.isCooked ? "Already cooked" : "Not yet cooked")
    }
}

#Preview {
    ZStack {
        Color.glassBackground.ignoresSafeArea()

        MenuRecipeCard(
            item: MenuItemWithRecipe(
                id: UUID(),
                recipe: Recipe(
                    userId: UUID(),
                    title: "Delicious Pasta",
                    sourceName: "TikTok"
                ),
                isCooked: false
            )
        )
        .environment(MenuState())
        .frame(width: 170)
        .padding()
    }
}
