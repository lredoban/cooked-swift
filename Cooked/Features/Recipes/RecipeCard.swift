import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image container with status badge
            ZStack(alignment: .topLeading) {
                AsyncImageView(url: recipe.imageUrl)
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .background(BoldSwiss.black.opacity(0.05))
                    .clipped()
                    .swissClip()
                    .accessibilityHidden(true)

                // Status badge in top-left corner
                if recipe.importStatus == .importing {
                    SwissStatusBadge(text: "IMPORTING")
                } else if recipe.importStatus == .pendingReview {
                    SwissStatusBadge(text: "READY")
                }
            }

            // Content area
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title.uppercased())
                    .font(.swissCaption(11))
                    .fontWeight(.bold)
                    .tracking(0.5)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(BoldSwiss.black)

                if let sourceName = recipe.sourceName {
                    Text(sourceName.uppercased())
                        .font(.swissCaption(10))
                        .tracking(0.5)
                        .foregroundStyle(BoldSwiss.black.opacity(0.5))
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BoldSwiss.white)
        }
        .swissBorder()
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
    HStack(spacing: 1) {
        RecipeCard(recipe: Recipe(
            userId: UUID(),
            title: "Delicious Pasta Recipe with Tomato Sauce",
            sourceName: "TikTok"
        ))

        RecipeCard(recipe: Recipe(
            userId: UUID(),
            title: "Quick Salad",
            sourceName: "Instagram",
            importStatus: .pendingReview
        ))
    }
    .padding()
    .background(BoldSwiss.white)
}
