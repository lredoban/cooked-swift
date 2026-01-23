import SwiftUI

struct RecipePreviewSheet: View {
    @Environment(RecipeState.self) private var recipeState
    @Environment(SupabaseService.self) private var supabase
    @Environment(\.dismiss) private var dismiss

    @State private var editableTitle: String = ""

    var body: some View {
        NavigationStack {
            if let recipe = recipeState.extractedRecipe {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let imageUrl = recipe.imageUrl {
                            AsyncImageView(url: imageUrl)
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Title")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("Recipe title", text: $editableTitle)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }

                        if let sourceName = recipe.sourceName {
                            HStack {
                                Image(systemName: "link")
                                Text(sourceName)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients (\(recipe.ingredients.count))")
                                .font(.headline)

                            ForEach(Array(recipe.ingredients.enumerated()), id: \.offset) { _, ingredient in
                                HStack {
                                    Text("\u{2022}")
                                    if let qty = ingredient.quantity {
                                        Text(qty)
                                            .fontWeight(.medium)
                                    }
                                    Text(ingredient.text)
                                }
                                .font(.subheadline)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Steps (\(recipe.steps.count))")
                                .font(.headline)

                            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                        .fontWeight(.bold)
                                        .frame(width: 24, alignment: .leading)
                                    Text(step)
                                }
                                .font(.subheadline)
                            }
                        }

                        if !recipe.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.headline)

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
                .navigationTitle("Preview Recipe")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            recipeState.cancelImport()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            Task {
                                if let userId = supabase.authUser?.id {
                                    recipeState.extractedRecipe?.title = editableTitle
                                    await recipeState.saveExtractedRecipe(userId: userId)
                                }
                            }
                        } label: {
                            if recipeState.isSaving {
                                ProgressView()
                            } else {
                                Text("Save")
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(recipeState.isSaving || editableTitle.isEmpty)
                    }
                }
                .onAppear {
                    editableTitle = recipe.title
                }
            }
        }
    }
}

#Preview {
    RecipePreviewSheet()
        .environment(RecipeState())
        .environment(SupabaseService.shared)
}
