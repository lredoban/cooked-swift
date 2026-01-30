import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImageView(url: recipe.imageUrl)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color.vintageMutedCocoa.opacity(0.1))
                    .clipped()
                    .cornerRadius(16)
                    .accessibilityHidden(true)

                if recipe.importStatus == .importing {
                    importBadge(text: "Importing...", icon: "arrow.down.circle.fill")
                } else if recipe.importStatus == .pendingReview {
                    importBadge(text: "Ready", icon: "checkmark.circle.fill")
                }
            }

            Text(recipe.title)
                .font(.vintageSubheadline)
                .foregroundColor(.vintageCoffee)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let sourceName = recipe.sourceName {
                Text(sourceName)
                    .font(.vintageCaption)
                    .foregroundStyle(Color.vintageMutedCocoa)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color.vintageWhite)
        .cornerRadius(20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view recipe details")
    }

    private func importBadge(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.vintageCaption)
        .fontWeight(.medium)
        .foregroundColor(.vintageCoffee)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.vintageMarigold.opacity(0.9))
        .cornerRadius(12)
        .padding(6)
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
    RecipeCard(recipe: Recipe(
        userId: UUID(),
        title: "Delicious Pasta Recipe with Tomato Sauce",
        sourceName: "TikTok"
    ))
    .frame(width: 160)
    .padding()
    .background(Color.vintageCream)
}
