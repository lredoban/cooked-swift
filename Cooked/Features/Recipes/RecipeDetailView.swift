import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeState.self) private var recipeState
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image with curved bottom edge
                if let imageUrl = recipe.imageUrl {
                    AsyncImageView(url: imageUrl)
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: ElectricUI.cornerRadius,
                                bottomTrailingRadius: ElectricUI.cornerRadius,
                                topTrailingRadius: 0
                            )
                        )
                }

                VStack(alignment: .leading, spacing: ElectricUI.sectionSpacing) {
                    // Title section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title)
                            .font(.electricDisplay)
                            .foregroundColor(.ink)

                        if let sourceName = recipe.sourceName {
                            HStack(spacing: 6) {
                                Image(systemName: sourceIcon)
                                    .foregroundColor(.hyperOrange)
                                Text(sourceName)
                                    .foregroundColor(.graphite)
                            }
                            .font(.electricCaption)
                        }
                    }

                    // Stats row
                    HStack(spacing: 20) {
                        if recipe.timesCooked > 0 {
                            StatBadge(
                                icon: "checkmark.circle.fill",
                                text: "\(recipe.timesCooked) cooked",
                                color: .hyperOrange
                            )
                        }
                        StatBadge(
                            icon: "list.bullet",
                            text: "\(recipe.ingredients.count) ingredients",
                            color: .graphite
                        )
                        StatBadge(
                            icon: "text.alignleft",
                            text: "\(recipe.steps.count) steps",
                            color: .graphite
                        )
                    }

                    // Ingredients section with soft yellow background
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ingredients")
                            .font(.electricHeadline)
                            .foregroundColor(.ink)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(recipe.ingredients) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(Color.hyperOrange)
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 6)

                                    VStack(alignment: .leading, spacing: 2) {
                                        if let qty = ingredient.quantity {
                                            Text(qty)
                                                .font(.electricBody)
                                                .fontWeight(.bold)
                                                .foregroundColor(.ink)
                                        }
                                        Text(ingredient.text)
                                            .font(.electricBody)
                                            .foregroundColor(.ink)
                                    }
                                }
                            }
                        }
                        .padding(ElectricUI.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.softYellow)
                        .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
                    }

                    // Instructions section with soft blue background
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instructions")
                            .font(.electricHeadline)
                            .foregroundColor(.ink)

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 16) {
                                    ElectricStepNumber(number: index + 1)

                                    Text(step)
                                        .font(.electricBody)
                                        .foregroundColor(.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(ElectricUI.cardPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.softBlue)
                        .clipShape(RoundedRectangle(cornerRadius: ElectricUI.cornerRadius))
                    }

                    // Tags section
                    if !recipe.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags")
                                .font(.electricHeadline)
                                .foregroundColor(.ink)

                            FlowLayout(spacing: 10) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.electricCaption)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.yolk)
                                        .foregroundColor(.ink)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(ElectricUI.cardPadding)
            }
        }
        .warmConcreteBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.hyperOrange)
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
            return "video.fill"
        case .url:
            return "link"
        case .manual:
            return "pencil"
        case .none:
            return "link"
        }
    }
}

// MARK: - Stat Badge Component

private struct StatBadge: View {
    let icon: String
    let text: String
    var color: Color = .graphite

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.electricCaption)
        .foregroundColor(color)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            userId: UUID(),
            title: "Delicious Pasta Carbonara",
            sourceType: .url,
            sourceName: "AllRecipes",
            ingredients: [
                Ingredient(text: "Spaghetti pasta", quantity: "1 lb"),
                Ingredient(text: "Pancetta or guanciale", quantity: "8 oz"),
                Ingredient(text: "Eggs", quantity: "4 large"),
                Ingredient(text: "Pecorino Romano cheese, grated", quantity: "1 cup"),
                Ingredient(text: "Black pepper", quantity: "2 tsp")
            ],
            steps: [
                "Bring a large pot of salted water to boil and cook pasta according to package directions until al dente.",
                "While pasta cooks, cut pancetta into small cubes and cook in a large skillet over medium heat until crispy.",
                "In a bowl, whisk together eggs, cheese, and pepper to make the sauce.",
                "When pasta is done, reserve 1 cup pasta water and drain. Add hot pasta to the skillet with pancetta.",
                "Remove from heat and quickly add egg mixture, tossing constantly to create a creamy sauce. Add pasta water as needed."
            ],
            tags: ["dinner", "italian", "pasta", "quick"]
        ))
        .environment(RecipeState())
    }
}
