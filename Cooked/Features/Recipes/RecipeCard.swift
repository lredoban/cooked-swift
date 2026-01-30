import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImageView(url: recipe.imageUrl)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color.dopamineSurface)
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
                .font(.dopamineSubheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let sourceName = recipe.sourceName {
                Text(sourceName)
                    .font(.dopamineCaption)
                    .foregroundStyle(Color.dopamineSecondary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view recipe details")
    }

    private func importBadge(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.dopamineCaption2)
        .fontWeight(.medium)
        .foregroundStyle(.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.dopamineAcid)
        .cornerRadius(8)
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
    .background(Color.dopamineBlack)
}
