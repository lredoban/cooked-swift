import SwiftUI

struct SelectableRecipeCard: View {
    let recipe: Recipe
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    AsyncImageView(url: recipe.imageUrl)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .clipped()
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 3)
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                            .background(Circle().fill(.white))
                            .padding(8)
                    }
                }

                Text(recipe.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        SelectableRecipeCard(
            recipe: Recipe(
                userId: UUID(),
                title: "Pasta Recipe",
                sourceName: "Test"
            ),
            isSelected: false,
            onTap: {}
        )

        SelectableRecipeCard(
            recipe: Recipe(
                userId: UUID(),
                title: "Selected Recipe",
                sourceName: "Test"
            ),
            isSelected: true,
            onTap: {}
        )
    }
    .padding()
}
