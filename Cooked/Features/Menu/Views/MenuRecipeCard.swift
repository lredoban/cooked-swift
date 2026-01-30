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
                    .background(Color.curatedBeige)
                    .clipped()
                    .cornerRadius(12)
                    .accessibilityHidden(true)

                Button {
                    Task {
                        await menuState.removeRecipeFromMenu(item)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.curatedCharcoal.opacity(0.6))
                }
                .padding(8)
                .accessibilityLabel("Remove \(item.recipe.title) from menu")
            }

            Text(item.recipe.title)
                .font(.curatedHeadline)
                .foregroundStyle(Color.curatedCharcoal)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .background(Color.curatedWhite)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(item.recipe.title)
        .accessibilityHint(item.isCooked ? "Already cooked" : "Not yet cooked")
    }
}

#Preview {
    ZStack {
        Color.curatedOatmeal.ignoresSafeArea()

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
    }
}
