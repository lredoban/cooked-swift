import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(RecipeState.self) private var recipeState
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    var body: some View {
        ZStack(alignment: .top) {
            // Full-bleed hero image
            GeometryReader { geometry in
                if let imageUrl = recipe.imageUrl {
                    AsyncImageView(url: imageUrl)
                        .frame(width: geometry.size.width, height: 300)
                        .clipped()

                    // Gradient fade to dark
                    LinearGradient(
                        colors: [.clear, Color.glassBackground.opacity(0.8), Color.glassBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 300)
                }
            }
            .ignoresSafeArea()

            // Glass sheet sliding up
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Spacer for hero image
                    Color.clear.frame(height: 220)

                    // Content sheet
                    VStack(alignment: .leading, spacing: 24) {
                        // Title section
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(.glassTitle(28))
                                .foregroundColor(.glassTextPrimary)

                            if let sourceName = recipe.sourceName {
                                HStack(spacing: 6) {
                                    Image(systemName: sourceIcon)
                                        .font(.glassCaption())
                                    Text(sourceName)
                                        .font(.glassMono(13))
                                }
                                .foregroundColor(.glassTextSecondary)
                            }
                        }

                        // Stats row
                        HStack(spacing: 20) {
                            if recipe.timesCooked > 0 {
                                statItem(icon: "checkmark.circle", text: "\(recipe.timesCooked) cooked")
                            }
                            statItem(icon: "list.bullet", text: "\(recipe.ingredients.count) ingredients")
                            statItem(icon: "text.alignleft", text: "\(recipe.steps.count) steps")
                        }
                        .font(.glassMono(12))
                        .foregroundColor(.glassTextSecondary)

                        // Divider
                        Rectangle()
                            .fill(Color.glassBorder)
                            .frame(height: 1)

                        // Ingredients section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ingredients")
                                .font(.glassHeadline(20))
                                .foregroundColor(.glassTextPrimary)

                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(recipe.ingredients) { ingredient in
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(LinearGradient.holographicOrange)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 8)

                                        VStack(alignment: .leading, spacing: 2) {
                                            if let qty = ingredient.quantity {
                                                Text(qty)
                                                    .font(.glassBodyMedium(14))
                                                    .foregroundColor(.glassTextPrimary)
                                            }
                                            Text(ingredient.text)
                                                .font(.glassBody(15))
                                                .foregroundColor(.glassTextSecondary)
                                        }
                                    }
                                }
                            }
                        }

                        // Divider
                        Rectangle()
                            .fill(Color.glassBorder)
                            .frame(height: 1)

                        // Instructions section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.glassHeadline(20))
                                .foregroundColor(.glassTextPrimary)

                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 14) {
                                        Text("\(index + 1)")
                                            .font(.glassHeadline(14))
                                            .foregroundColor(.glassBackground)
                                            .frame(width: 28, height: 28)
                                            .background(LinearGradient.holographicOrange)
                                            .clipShape(Circle())

                                        Text(step)
                                            .font(.glassBody(15))
                                            .foregroundColor(.glassTextSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }

                        // Tags section
                        if !recipe.tags.isEmpty {
                            Rectangle()
                                .fill(Color.glassBorder)
                                .frame(height: 1)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tags")
                                    .font(.glassHeadline(20))
                                    .foregroundColor(.glassTextPrimary)

                                FlowLayout(spacing: 8) {
                                    ForEach(recipe.tags, id: \.self) { tag in
                                        GlassChip(text: tag)
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color.glassBackground)
                    )
                }
            }
        }
        .spatialBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.glassTextSecondary)
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
        .preferredColorScheme(.dark)
    }

    private func statItem(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
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
