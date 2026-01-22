import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeState.self) private var recipeState
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageUrl = recipe.imageUrl {
                    AsyncImageView(url: imageUrl)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.title)
                            .font(.title)
                            .fontWeight(.bold)

                        if let sourceName = recipe.sourceName {
                            HStack {
                                Image(systemName: sourceIcon)
                                Text(sourceName)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 20) {
                        if recipe.timesCooked > 0 {
                            Label("\(recipe.timesCooked) cooked", systemImage: "checkmark.circle")
                        }
                        Label("\(recipe.ingredients.count) ingredients", systemImage: "list.bullet")
                        Label("\(recipe.steps.count) steps", systemImage: "text.alignleft")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)

                        ForEach(recipe.ingredients) { ingredient in
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)

                                VStack(alignment: .leading) {
                                    if let qty = ingredient.quantity {
                                        Text(qty)
                                            .fontWeight(.medium)
                                    }
                                    Text(ingredient.text)
                                }
                            }
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)

                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.orange)
                                    .clipShape(Circle())

                                Text(step)
                                    .font(.body)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if !recipe.tags.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.title2)
                                .fontWeight(.semibold)

                            FlowLayout(spacing: 8) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundStyle(.orange)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog("Delete Recipe?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await recipeState.deleteRecipe(recipe)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var sourceIcon: String {
        switch recipe.sourceType {
        case .video:
            return "video"
        case .url:
            return "link"
        case .manual:
            return "pencil"
        case .none:
            return "link"
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            userId: UUID(),
            title: "Delicious Pasta",
            sourceType: .url,
            sourceName: "AllRecipes",
            ingredients: [
                Ingredient(text: "Pasta", quantity: "1 lb"),
                Ingredient(text: "Tomato sauce", quantity: "2 cups")
            ],
            steps: ["Boil water", "Cook pasta", "Add sauce"],
            tags: ["dinner", "italian", "quick"]
        ))
        .environment(RecipeState())
    }
}
