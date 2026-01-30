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
                            .font(.dopamineTitle2)
                            .foregroundStyle(.white)

                        if let sourceName = recipe.sourceName {
                            HStack {
                                Image(systemName: sourceIcon)
                                Text(sourceName)
                            }
                            .font(.dopamineCaption)
                            .foregroundStyle(Color.dopamineSecondary)
                        }
                    }

                    HStack(spacing: 20) {
                        if recipe.timesCooked > 0 {
                            Label("\(recipe.timesCooked) cooked", systemImage: "checkmark.circle")
                                .foregroundStyle(Color.dopamineAcid)
                        }
                        Label("\(recipe.ingredients.count) ingredients", systemImage: "list.bullet")
                        Label("\(recipe.steps.count) steps", systemImage: "text.alignleft")
                    }
                    .font(.dopamineCaption)
                    .foregroundStyle(Color.dopamineSecondary)

                    Rectangle()
                        .fill(Color.dopamineSurface)
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.dopamineTitle3)
                            .foregroundStyle(.white)

                        ForEach(recipe.ingredients) { ingredient in
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(Color.dopamineAcid)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)

                                VStack(alignment: .leading) {
                                    if let qty = ingredient.quantity {
                                        Text(qty)
                                            .font(.dopamineBodyMedium)
                                            .foregroundStyle(Color.dopamineYellow)
                                    }
                                    Text(ingredient.text)
                                        .font(.dopamineBodyRegular)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }

                    Rectangle()
                        .fill(Color.dopamineSurface)
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.dopamineTitle3)
                            .foregroundStyle(.white)

                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.dopamineHeadline)
                                    .foregroundStyle(.black)
                                    .frame(width: 28, height: 28)
                                    .background(Color.dopamineAcid)
                                    .clipShape(Circle())

                                Text(step)
                                    .font(.dopamineBodyRegular)
                                    .foregroundStyle(.white)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if !recipe.tags.isEmpty {
                        Rectangle()
                            .fill(Color.dopamineSurface)
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.dopamineTitle3)
                                .foregroundStyle(.white)

                            FlowLayout(spacing: 8) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.dopamineCaption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.dopaminePink.opacity(0.2))
                                        .foregroundStyle(Color.dopaminePink)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.dopamineBlack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.dopaminePink)
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
