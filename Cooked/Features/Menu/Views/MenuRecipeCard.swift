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
                    .background(Color.dopamineSurface)
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
                        .foregroundStyle(Color.dopamineBlack, Color.dopaminePink)
                }
                .padding(8)
                .accessibilityLabel("Remove \(item.recipe.title) from menu")
            }

            Text(item.recipe.title)
                .font(.dopamineSubheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
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
    .background(Color.dopamineBlack)
}
