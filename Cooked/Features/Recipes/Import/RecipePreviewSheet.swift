import SwiftUI

struct RecipePreviewSheet: View {
    @Environment(RecipeState.self) private var recipeState
    @Environment(SupabaseService.self) private var supabase
    @Environment(\.dismiss) private var dismiss

    @State private var editableTitle: String = ""

    var body: some View {
        NavigationStack {
            Group {
                if let stage = recipeState.importStage {
                    contentForStage(stage)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Import Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        recipeState.cancelImport()
                    }
                }
            }
            .onAppear {
                if let metadata = recipeState.importMetadata {
                    editableTitle = metadata.title
                }
            }
        }
    }

    // MARK: - Stage Router

    @ViewBuilder
    private func contentForStage(_ stage: ImportStage) -> some View {
        switch stage {
        case .triggering, .waitingForStream:
            extractingView(message: "Connecting...")

        case .progress(_, let message):
            extractingView(message: message)

        case .complete:
            completeView

        case .failed(let reason):
            failedView(reason: reason)

        case .backgrounded:
            backgroundedView
        }
    }

    // MARK: - Extracting View (shimmer + metadata)

    private func extractingView(message: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                metadataHeader

                // Progress indicator
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(.orange)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)

                // Shimmer placeholders for ingredients & steps
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)
                    ShimmerBlock(lineCount: 5)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps")
                        .font(.headline)
                    ShimmerBlock(lineCount: 4, lineHeight: 16, spacing: 12)
                }
            }
            .padding()
        }
    }

    // MARK: - Complete View (edit mode)

    private var completeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                metadataHeader

                // Banner
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Recipe ready — review and save")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)

                if let recipeId = recipeState.importingRecipeId,
                   let recipe = recipeState.recipes.first(where: { $0.id == recipeId }) {
                    ingredientsSection(recipe.ingredients)
                    stepsSection(recipe.steps)
                    tagsSection(recipe.tags)
                }

                // Action buttons
                actionButtons
            }
            .padding()
        }
    }

    // MARK: - Failed View

    private func failedView(reason: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Extraction Failed")
                .font(.title2)
                .fontWeight(.semibold)

            Text(reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await recipeState.triggerImport()
                }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Backgrounded View

    private var backgroundedView: some View {
        VStack(spacing: 24) {
            Spacer()

            if let metadata = recipeState.importMetadata {
                AsyncImageView(url: metadata.imageUrl)
                    .frame(height: 120)
                    .frame(maxWidth: 200)
                    .clipped()
                    .cornerRadius(12)
            }

            Text("Still working on it...")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Video recipes take a bit longer to process. We'll notify you when it's ready.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    recipeState.backgroundImport()
                } label: {
                    Text("Continue Browsing")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)

                Button {
                    // Reset to extracting state to keep waiting
                    recipeState.importStage = .waitingForStream
                } label: {
                    Text("Keep Waiting")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    // MARK: - Shared Components

    private var metadataHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let metadata = recipeState.importMetadata {
                AsyncImageView(url: metadata.imageUrl)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Recipe title", text: $editableTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                if let sourceName = metadata.sourceName {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                        Text(sourceName)
                        if let platform = metadata.platform {
                            Text("·")
                            Text(platform)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func ingredientsSection(_ ingredients: [Ingredient]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients (\(ingredients.count))")
                .font(.headline)

            ForEach(ingredients) { ingredient in
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
    }

    private func stepsSection(_ steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Steps (\(steps.count))")
                .font(.headline)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                        .fontWeight(.bold)
                        .frame(width: 24, alignment: .leading)
                    Text(step)
                }
                .font(.subheadline)
            }
        }
    }

    @ViewBuilder
    private func tagsSection(_ tags: [String]) -> some View {
        if !tags.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tags")
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
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

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    if let userId = supabase.authUser?.id {
                        await recipeState.confirmRecipe(userId: userId, editedTitle: editableTitle)
                    }
                }
            } label: {
                if recipeState.isSaving {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Label("Save", systemImage: "book")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(recipeState.isSaving || editableTitle.isEmpty)
        }
    }
}

#Preview {
    RecipePreviewSheet()
        .environment(RecipeState())
        .environment(SupabaseService.shared)
}
