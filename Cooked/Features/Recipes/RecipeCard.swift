import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-bleed image with 24px radius
            AsyncImageView(url: recipe.imageUrl)
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .background(Color.warmConcrete)
                .clipped()

            // Status badge floating top right
            VStack {
                HStack {
                    Spacer()

                    if recipe.importStatus == .importing {
                        StickerBadge(
                            text: "Importing",
                            icon: "arrow.down.circle.fill",
                            color: .cobalt
                        )
                    } else if recipe.importStatus == .pendingReview {
                        StickerBadge(
                            text: "Ready",
                            icon: "checkmark.circle.fill",
                            color: .hyperOrange
                        )
                    }
                }
                .padding(10)

                Spacer()
            }

            // Floating title pill at bottom
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.electricSubheadline)
                    .foregroundColor(.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let sourceName = recipe.sourceName {
                    Text(sourceName)
                        .font(.electricCaption)
                        .foregroundColor(.graphite)
                        .lineLimit(1)
                }
            }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view recipe details")
    }

    private var accessibilityLabel: String {
        var label = recipe.title
        if let source = recipe.sourceName {
            label += ", from \(source)"
        }
        if recipe.timesCooked > 0 {
            label += ", cooked \(recipe.timesCooked) time\(recipe.timesCooked == 1 ? "" : "s")"
        }
        return label
    }
}

#Preview {
    VStack(spacing: 20) {
        RecipeCard(recipe: Recipe(
            userId: UUID(),
            title: "Delicious Pasta Recipe with Tomato Sauce",
            sourceName: "TikTok"
        ))
        .frame(width: 180)

        RecipeCard(recipe: Recipe(
            userId: UUID(),
            title: "Quick Chicken Stir Fry",
            sourceName: "Instagram",
            importStatus: .pendingReview
        ))
        .frame(width: 180)
    }
    .padding()
    .warmConcreteBackground()
}
