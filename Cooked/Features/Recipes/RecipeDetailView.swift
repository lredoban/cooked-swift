import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeState.self) private var recipeState
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image with hard black line separator
                if let imageUrl = recipe.imageUrl {
                    AsyncImageView(url: imageUrl)
                        .frame(height: 280)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .swissClip()
                }

                SwissDivider(thickness: 2)

                VStack(alignment: .leading, spacing: 0) {
                    // Title - HUGE, can span multiple lines
                    Text(recipe.title.uppercased())
                        .font(.swissDisplay(32))
                        .tracking(1)
                        .foregroundStyle(BoldSwiss.black)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 12)

                    // Source info
                    if let sourceName = recipe.sourceName {
                        HStack(spacing: 8) {
                            Image(systemName: sourceIcon)
                                .font(.system(size: 12, weight: .bold))
                            Text(sourceName.uppercased())
                                .font(.swissCaption(12))
                                .tracking(1)
                        }
                        .foregroundStyle(BoldSwiss.black.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }

                    // Stats bar
                    HStack(spacing: 0) {
                        if recipe.timesCooked > 0 {
                            statItem(value: "\(recipe.timesCooked)", label: "COOKED")
                            Rectangle()
                                .fill(BoldSwiss.black)
                                .frame(width: 1)
                        }
                        statItem(value: "\(recipe.ingredients.count)", label: "INGREDIENTS")
                        Rectangle()
                            .fill(BoldSwiss.black)
                            .frame(width: 1)
                        statItem(value: "\(recipe.steps.count)", label: "STEPS")
                    }
                    .frame(height: 60)
                    .swissBorder()
                    .padding(.horizontal, 16)

                    // Ingredients section - nutrition label style
                    VStack(alignment: .leading, spacing: 0) {
                        Text("INGREDIENTS")
                            .swissSectionHeader()

                        ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { index, ingredient in
                            HStack(alignment: .top, spacing: 0) {
                                // Quantity on left, bold
                                if let qty = ingredient.quantity {
                                    Text(qty.uppercased())
                                        .font(.swissBody(14))
                                        .fontWeight(.bold)
                                        .foregroundStyle(BoldSwiss.black)
                                        .frame(width: 100, alignment: .leading)
                                } else {
                                    Spacer()
                                        .frame(width: 100)
                                }

                                // Item name standard weight on right
                                Text(ingredient.text)
                                    .font(.swissBody(14))
                                    .foregroundStyle(BoldSwiss.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)

                            // Heavy black separator
                            if index < recipe.ingredients.count - 1 {
                                SwissDivider()
                            }
                        }
                    }
                    .swissBorder()
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Instructions section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("INSTRUCTIONS")
                            .swissSectionHeader()

                        ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                // Large bold step number
                                Text(String(format: "%02d", index + 1))
                                    .font(.swissStepNumber(24))
                                    .foregroundStyle(BoldSwiss.black)
                                    .frame(width: 40, alignment: .leading)

                                // Step text
                                Text(step)
                                    .font(.swissBody(15))
                                    .foregroundStyle(BoldSwiss.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)

                            if index < recipe.steps.count - 1 {
                                SwissDivider()
                            }
                        }
                    }
                    .swissBorder()
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                    // Tags section
                    if !recipe.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("TAGS")
                                .swissSectionHeader()

                            FlowLayout(spacing: 8) {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag.uppercased())
                                        .font(.swissCaption(11))
                                        .fontWeight(.medium)
                                        .tracking(1)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundStyle(BoldSwiss.black)
                                        .swissBorder()
                                }
                            }
                            .padding(16)
                        }
                        .swissBorder()
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(BoldSwiss.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(BoldSwiss.black)
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

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.swissHeader(20))
                .foregroundStyle(BoldSwiss.black)
            Text(label)
                .font(.swissCaption(9))
                .tracking(1)
                .foregroundStyle(BoldSwiss.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
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
            title: "Delicious Pasta Carbonara",
            sourceType: .url,
            sourceName: "AllRecipes",
            ingredients: [
                Ingredient(text: "Spaghetti pasta", quantity: "1 lb"),
                Ingredient(text: "Pancetta or guanciale", quantity: "8 oz"),
                Ingredient(text: "Eggs", quantity: "4 large"),
                Ingredient(text: "Pecorino Romano", quantity: "1 cup"),
                Ingredient(text: "Black pepper", quantity: "2 tsp")
            ],
            steps: [
                "Bring a large pot of salted water to boil and cook pasta according to package directions until al dente.",
                "While pasta cooks, cut the pancetta into small cubes and cook in a large skillet over medium heat until crispy.",
                "In a bowl, whisk together eggs, grated cheese, and plenty of black pepper.",
                "When pasta is done, reserve 1 cup pasta water and drain. Add hot pasta to the skillet with pancetta.",
                "Remove from heat and quickly pour egg mixture over pasta, tossing constantly to create a creamy sauce.",
                "Add pasta water as needed to achieve desired consistency. Serve immediately with extra cheese and pepper."
            ],
            tags: ["dinner", "italian", "quick", "comfort food"]
        ))
        .environment(RecipeState())
    }
}
