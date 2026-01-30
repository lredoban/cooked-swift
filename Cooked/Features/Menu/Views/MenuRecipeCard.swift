import SwiftUI

struct MenuRecipeCard: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with remove button
            ZStack(alignment: .topTrailing) {
                AsyncImageView(url: item.recipe.imageUrl)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(BoldSwiss.black.opacity(0.05))
                    .clipped()
                    .swissClip()
                    .accessibilityHidden(true)

                // Remove button - square black button
                Button {
                    Task {
                        await menuState.removeRecipeFromMenu(item)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(BoldSwiss.white)
                        .frame(width: 24, height: 24)
                        .background(BoldSwiss.black)
                        .swissClip()
                }
                .padding(8)
                .accessibilityLabel("Remove \(item.recipe.title) from menu")
            }

            // Title
            Text(item.recipe.title.uppercased())
                .font(.swissCaption(11))
                .fontWeight(.bold)
                .tracking(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundStyle(BoldSwiss.black)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BoldSwiss.white)
        }
        .swissBorder()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(item.recipe.title)
        .accessibilityHint(item.isCooked ? "Already cooked" : "Not yet cooked")
    }
}

#Preview {
    HStack(spacing: 1) {
        MenuRecipeCard(
            item: MenuItemWithRecipe(
                id: UUID(),
                recipe: Recipe(
                    userId: UUID(),
                    title: "Delicious Pasta with Fresh Tomatoes",
                    sourceName: "TikTok"
                ),
                isCooked: false
            )
        )

        MenuRecipeCard(
            item: MenuItemWithRecipe(
                id: UUID(),
                recipe: Recipe(
                    userId: UUID(),
                    title: "Quick Salad",
                    sourceName: "Instagram"
                ),
                isCooked: true
            )
        )
    }
    .environment(MenuState())
    .padding()
    .background(BoldSwiss.white)
}
