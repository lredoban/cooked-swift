import SwiftUI

struct ImportRecipeSheet: View {
    @Environment(RecipeState.self) private var recipeState
    @Environment(SubscriptionState.self) private var subscriptionState
    @Environment(\.dismiss) private var dismiss

    private var isAtRecipeLimit: Bool {
        !subscriptionState.canAddRecipe(currentCount: recipeState.recipes.count)
    }

    var body: some View {
        @Bindable var state = recipeState

        NavigationStack {
            Group {
                if isAtRecipeLimit {
                    recipeLimitView
                } else {
                    importFormView
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
            .sheet(isPresented: Binding(
                get: { subscriptionState.isShowingPaywall },
                set: { subscriptionState.isShowingPaywall = $0 }
            )) {
                PaywallView()
            }
        }
    }

    // MARK: - Recipe Limit View

    private var recipeLimitView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Recipe Limit Reached")
                .font(.title2)
                .fontWeight(.semibold)

            Text("You've saved \(FreemiumLimits.freeRecipeLimit) recipes.\nUpgrade to Pro for unlimited recipes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button {
                subscriptionState.showPaywall()
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    // MARK: - Import Form View

    private var importFormView: some View {
        @Bindable var state = recipeState

        return VStack(spacing: 24) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
                .padding(.top, 32)

            Text("Paste a recipe URL")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Works with TikTok, Instagram, YouTube, and most recipe websites")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Remaining recipes indicator
            let remaining = subscriptionState.recipesRemaining(currentCount: recipeState.recipes.count)
            Text("\(remaining) recipe\(remaining == 1 ? "" : "s") remaining")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                TextField("https://...", text: $state.importURL)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                Button {
                    if let clipboardString = UIPasteboard.general.string {
                        recipeState.importURL = clipboardString
                    }
                } label: {
                    Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                        .font(.subheadline)
                }
            }
            .padding(.horizontal)

            if let error = recipeState.extractionError {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Spacer()

            Button {
                Task {
                    await recipeState.extractRecipe()
                }
            } label: {
                if recipeState.isExtracting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Import Recipe")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(recipeState.importURL.isEmpty || recipeState.isExtracting)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    ImportRecipeSheet()
        .environment(RecipeState())
        .environment(SubscriptionState())
}
