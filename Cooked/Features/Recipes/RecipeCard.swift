import SwiftUI

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImageView(url: recipe.imageUrl)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .clipped()
                .cornerRadius(12)

            Text(recipe.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let sourceName = recipe.sourceName {
                Text(sourceName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
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
}
