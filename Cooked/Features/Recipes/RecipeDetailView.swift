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
                        Text(recipe.title.uppercased())
                            .font(.vintageTitle)
                            .foregroundColor(.vintageCoffee)

                        if let sourceName = recipe.sourceName {
                            HStack {
                                Image(systemName: sourceIcon)
                                Text(sourceName)
                            }
                            .font(.vintageCaption)
                            .foregroundStyle(Color.vintageMutedCocoa)
                        }
                    }

                    HStack(spacing: 20) {
                        if recipe.timesCooked > 0 {
                            Label("\(recipe.timesCooked) cooked", systemImage: "checkmark.circle")
                        }
                        Label("\(recipe.ingredients.count) ingredients", systemImage: "list.bullet")
                        Label("\(recipe.steps.count) steps", systemImage: "text.alignleft")
                    }
                    .font(.vintageCaption)
                    .foregroundStyle(Color.vintageMutedCocoa)

                    Rectangle()
                        .fill(Color.vintageMutedCocoa.opacity(0.2))
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("INGREDIENTS")
                            .font(.vintageHeadline)
                            .foregroundColor(.vintageCoffee)

                        ForEach(recipe.ingredients) { ingredient in
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(Color.vintageTangerine)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)

                                VStack(alignment: .leading) {
                                    if let qty = ingredient.quantity {
                                        Text(qty)
                                            .font(.vintageBody)
                                            .fontWeight(.medium)
                                            .foregroundColor(.vintageCoffee)
                                    }
                                    Text(ingredient.text)
                                        .font(.vintageBody)
                                        .foregroundColor(.vintageCoffee)
                                }
                            }
                        }
                    }

                    Rectangle()
                        .fill(Color.vintageMutedCocoa.opacity(0.2))
                        .frame(height: 1)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("INSTRUCTIONS")
                            .font(.vintageHeadline)
                            .foregroundColor(.vintageCoffee)

                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.vintageButton)
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.vintageTangerine)
                                    .clipShape(Circle())

                                Text(step)
                                    .font(.vintageBody)
                                    .foregroundColor(.vintageCoffee)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if !recipe.tags.isEmpty {
                        Rectangle()
                            .fill(Color.vintageMutedCocoa.opacity(0.2))
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("TAGS")
                                .font(.vintageHeadline)
                                .foregroundColor(.vintageCoffee)

                            FlowLayout(spacing: 8) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.vintageCaption)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.vintageMarigold.opacity(0.2))
                                        .foregroundStyle(Color.vintageMutedCocoa)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.vintageCream)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.vintageBurnt)
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
