import SwiftUI

struct MenuRecipeCard: View {
    let item: MenuItemWithRecipe
    @Environment(MenuState.self) private var menuState

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed image with 24px radius
            AsyncImageView(url: item.recipe.imageUrl)
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .background(Color.warmConcrete)
                .clipped()

            // Remove button floating top right as sticker
            VStack {
                HStack {
                    Spacer()

                    Button {
                        Task {
                            await menuState.removeRecipeFromMenu(item)
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(Color.ink.opacity(0.7))
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                    }
                    .accessibilityLabel("Remove \(item.recipe.title) from menu")
                }
                .padding(10)

                Spacer()
            }

            // Floating title pill at bottom
            Text(item.recipe.title)
                .font(.electricSubheadline)
                .foregroundColor(.ink)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: ElectricUI.smallCornerRadius)
                        .fill(Color.surfaceWhite.opacity(0.95))
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                )
                .padding(8)
        }
        .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
        .shadow(
            color: .black.opacity(ElectricUI.cardShadowOpacity),
            radius: ElectricUI.cardShadowRadius,
            x: 0,
            y: ElectricUI.cardShadowY
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(item.recipe.title)
        .accessibilityHint(item.isCooked ? "Already cooked" : "Not yet cooked")
    }
}

#Preview {
    VStack(spacing: 20) {
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
        .frame(width: 180)

        MenuRecipeCard(
            item: MenuItemWithRecipe(
                id: UUID(),
                recipe: Recipe(
                    userId: UUID(),
                    title: "Quick Chicken Stir Fry with Vegetables",
                    sourceName: "Instagram"
                ),
                isCooked: true
            )
        )
        .frame(width: 180)
    }
    .padding()
    .warmConcreteBackground()
    .environment(MenuState())
}
