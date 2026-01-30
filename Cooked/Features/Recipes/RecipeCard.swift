import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        FrostedImageCard(imageUrl: recipe.imageUrl, height: 180) {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.glassBodyMedium(14))
                    .foregroundColor(.glassTextPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let sourceName = recipe.sourceName {
                    Text(sourceName)
                        .font(.glassMono(11))
                        .foregroundColor(.glassTextSecondary)
                        .lineLimit(1)
                }

                if recipe.timesCooked > 0 {
                    Text("Cooked \(recipe.timesCooked) time\(recipe.timesCooked == 1 ? "" : "s")")
                        .font(.glassMono(10))
                        .foregroundColor(.glassTextTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .topTrailing) {
            if recipe.importStatus == .importing {
                importBadge(text: "Importing...", icon: "arrow.down.circle.fill")
            } else if recipe.importStatus == .pendingReview {
                importBadge(text: "Ready", icon: "checkmark.circle.fill")
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
        .font(.glassMono(10))
        .foregroundColor(.glassTextPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.glassSurface)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .padding(8)
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
    ZStack {
        Color.glassBackground.ignoresSafeArea()

        RecipeCard(recipe: Recipe(
            userId: UUID(),
            title: "Delicious Pasta Recipe with Tomato Sauce",
            sourceName: "TikTok",
            timesCooked: 3
        ))
        .frame(width: 170)
        .padding()
    }
}
