import SwiftUI

struct ImportRecipeSheet: View {
    @Environment(RecipeState.self) private var recipeState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var state = recipeState

        NavigationStack {
            VStack(spacing: 24) {
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
            .navigationTitle("Import Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        recipeState.cancelImport()
                    }
                }
            }
        }
    }
}

#Preview {
    ImportRecipeSheet()
        .environment(RecipeState())
}
