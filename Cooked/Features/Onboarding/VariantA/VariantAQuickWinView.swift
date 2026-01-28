//
//  VariantAQuickWinView.swift
//  Cooked
//
//  Guided first action: user taps to add recipes to their first menu.
//

import SwiftUI

struct VariantAQuickWinView: View {
    let onContinue: () -> Void

    @State private var selectedRecipes: Set<Int> = []
    @State private var showCelebration = false

    private let sampleRecipes = [
        (0, "One-Pan Salmon & Veggies", "25 min", "flame.fill"),
        (1, "Chicken Caesar Wraps", "15 min", "leaf.fill"),
        (2, "Veggie Fried Rice", "20 min", "frying.pan.fill"),
        (3, "Sheet Pan Fajitas", "30 min", "flame"),
    ]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Build your first menu")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Text("Tap 2-3 recipes to add to this week's menu.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sampleRecipes, id: \.0) { recipe in
                        let isSelected = selectedRecipes.contains(recipe.0)
                        Button {
                            withAnimation(.spring(duration: 0.25)) {
                                if isSelected {
                                    selectedRecipes.remove(recipe.0)
                                } else {
                                    selectedRecipes.insert(recipe.0)
                                }
                            }
                            checkCompletion()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: recipe.3)
                                    .font(.title3)
                                    .foregroundStyle(isSelected ? .white : .orange)
                                    .frame(width: 40, height: 40)
                                    .background(isSelected ? Color.orange : Color.orange.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(recipe.1)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Text(recipe.2)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isSelected ? .orange : Color(.systemGray3))
                                    .font(.title3)
                            }
                            .padding(14)
                            .background(isSelected ? Color.orange.opacity(0.08) : Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(isSelected ? Color.orange : .clear, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }

            if showCelebration {
                VStack(spacing: 8) {
                    Text("Your menu is set!")
                        .font(.headline)
                        .foregroundStyle(.orange)

                    Text("\(selectedRecipes.count) recipes ready to cook this week")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            Button(action: onContinue) {
                Text(showCelebration ? "Continue" : "Add \(selectedRecipes.count) recipes")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedRecipes.count >= 2 ? Color.orange : Color(.systemGray4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedRecipes.count < 2)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func checkCompletion() {
        if selectedRecipes.count >= 2 && !showCelebration {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(200))
                withAnimation(.spring(duration: 0.4)) {
                    showCelebration = true
                }
            }
        } else if selectedRecipes.count < 2 {
            showCelebration = false
        }
    }
}
