import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeState.self) private var recipeState
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                if let imageUrl = recipe.imageUrl {
                    AsyncImageView(url: imageUrl)
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }

                VStack(alignment: .leading, spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title)
                            .font(.curatedTitle)
                            .foregroundStyle(Color.curatedCharcoal)

                        if let sourceName = recipe.sourceName {
                            HStack(spacing: 6) {
                                Image(systemName: sourceIcon)
                                    .font(.curatedCaption)
                                Text(sourceName.uppercased())
                                    .font(.curatedCaption)
                                    .tracking(0.5)
                            }
                            .foregroundStyle(Color.curatedWarmGrey)
                        }
                    }

                    // Stats Row
                    HStack(spacing: 20) {
                        if recipe.timesCooked > 0 {
                            statItem(
                                icon: "checkmark.circle",
                                text: "\(recipe.timesCooked) cooked"
                            )
                        }
                        statItem(
                            icon: "list.bullet",
                            text: "\(recipe.ingredients.count) ingredients"
                        )
                        statItem(
                            icon: "text.alignleft",
                            text: "\(recipe.steps.count) steps"
                        )
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.curatedBeige)
                        .frame(height: 1)

                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ingredients")
                            .font(.curatedTitle2)
                            .foregroundStyle(Color.curatedCharcoal)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(recipe.ingredients) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(Color.curatedTerracotta)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 7)

                                    VStack(alignment: .leading, spacing: 2) {
                                        if let qty = ingredient.quantity {
                                            Text(qty)
                                                .font(.curatedSans(size: 15, weight: .semibold))
                                                .foregroundStyle(Color.curatedCharcoal)
                                        }
                                        Text(ingredient.text)
                                            .font(.curatedBody)
                                            .foregroundStyle(Color.curatedCharcoal)
                                    }
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.curatedBeige)
                        .frame(height: 1)

                    // Instructions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instructions")
                            .font(.curatedTitle2)
                            .foregroundStyle(Color.curatedCharcoal)

                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 16) {
                                    Text("\(index + 1)")
                                        .font(.curatedSans(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.curatedTerracotta)
                                        .clipShape(Circle())

                                    Text(step)
                                        .font(.curatedBody)
                                        .foregroundStyle(Color.curatedCharcoal)
                                        .lineSpacing(4)
                                }
                            }
                        }
                    }

                    // Tags Section
                    if !recipe.tags.isEmpty {
                        Rectangle()
                            .fill(Color.curatedBeige)
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags")
                                .font(.curatedTitle2)
                                .foregroundStyle(Color.curatedCharcoal)

                            FlowLayout(spacing: 8) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.curatedCaption)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.clear)
                                        .foregroundStyle(Color.curatedSage)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(Color.curatedSage, lineWidth: 1)
                                        )
                                        .cornerRadius(24)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
        }
        .curatedBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.curatedTerracotta)
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

    private func statItem(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.curatedCaption)
            .foregroundStyle(Color.curatedWarmGrey)
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
