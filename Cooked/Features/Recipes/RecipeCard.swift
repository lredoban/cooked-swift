import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                AsyncImageView(url: recipe.imageUrl)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color.curatedBeige)
                    .clipped()
                    .cornerRadius(12)
                    .accessibilityHidden(true)

                if recipe.importStatus == .importing {
                    importBadge(text: "Importing...", icon: "arrow.down.circle.fill")
                } else if recipe.importStatus == .pendingReview {
                    importBadge(text: "Ready", icon: "checkmark.circle.fill")
                }
            }

            Text(recipe.title)
                .font(.curatedHeadline)
                .foregroundStyle(Color.curatedCharcoal)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let sourceName = recipe.sourceName {
                Text(sourceName.uppercased())
                    .font(.curatedCaption2)
                    .foregroundStyle(Color.curatedWarmGrey)
                    .lineLimit(1)
                    .tracking(0.5)
            }
        }
        .padding(12)
        .background(Color.curatedWhite)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view recipe details")
    }

    private func importBadge(text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.curatedCaption2)
        .fontWeight(.medium)
        .foregroundStyle(Color.curatedSage)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.curatedWhite.opacity(0.95))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.curatedSage, lineWidth: 1)
        )
        .cornerRadius(24)
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
    ZStack {
        Color.curatedOatmeal.ignoresSafeArea()

        RecipeCard(recipe: Recipe(
            userId: UUID(),
            title: "Delicious Pasta Recipe with Tomato Sauce",
            sourceName: "TikTok"
        ))
        .frame(width: 160)
        .padding()
    }
}
