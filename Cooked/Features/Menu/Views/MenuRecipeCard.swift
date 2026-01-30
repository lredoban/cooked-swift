import SwiftUI

struct MenuRecipeCard: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImageView(url: item.recipe.imageUrl)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color.vintageMutedCocoa.opacity(0.1))
                    .clipped()
                    .cornerRadius(16)
                    .accessibilityHidden(true)

                Button {
                    Task {
                        await menuState.removeRecipeFromMenu(item)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.vintageCoffee.opacity(0.6))
                }
                .padding(8)
                .accessibilityLabel("Remove \(item.recipe.title) from menu")
            }

            Text(item.recipe.title)
                .font(.vintageSubheadline)
                .foregroundColor(.vintageCoffee)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .background(Color.vintageWhite)
        .cornerRadius(20)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(item.recipe.title)
        .accessibilityHint(item.isCooked ? "Already cooked" : "Not yet cooked")
    }
}

#Preview {
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
    .frame(width: 160)
    .padding()
    .background(Color.vintageCream)
}
