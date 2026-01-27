//
//  VariantAMagicMomentView.swift
//  Cooked
//
//  Demonstrates the core menu-building magic automatically.
//  Shows sample recipes being added to a menu and a grocery list generating.
//

import SwiftUI

struct VariantAMagicMomentView: View {
    let onContinue: () -> Void

    @State private var phase: AnimationPhase = .idle
    @State private var visibleRecipes: Int = 0
    @State private var showList = false
    @State private var showCTA = false

    private enum AnimationPhase {
        case idle, addingRecipes, generatingList, complete
    }

    private let demoRecipes = [
        ("Lemon Herb Chicken", "fork.knife", Color.orange),
        ("Pasta Primavera", "leaf.fill", Color.green),
        ("Thai Basil Stir-Fry", "flame.fill", Color.red),
    ]

    private let demoGroceryItems = [
        "Chicken breast (2 lbs)", "Pasta (1 box)", "Fresh basil",
        "Lemons (3)", "Bell peppers (2)", "Soy sauce",
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Here's how Cooked works")
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            // Menu card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.orange)
                    Text("This Week's Menu")
                        .font(.headline)
                }

                ForEach(0..<visibleRecipes, id: \.self) { index in
                    HStack(spacing: 12) {
                        Image(systemName: demoRecipes[index].1)
                            .foregroundStyle(demoRecipes[index].2)
                            .frame(width: 28)
                        Text(demoRecipes[index].0)
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)

            // Arrow
            if showList {
                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .transition(.opacity)
            }

            // Grocery list card
            if showList {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundStyle(.orange)
                        Text("Grocery List")
                            .font(.headline)
                    }

                    ForEach(demoGroceryItems, id: \.self) { item in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()

            if showCTA {
                Button(action: onContinue) {
                    Text("That's it — let's go!")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .transition(.opacity)
            }
        }
        .padding(.bottom, 24)
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        // Add recipes one by one
        Task { @MainActor in
            phase = .addingRecipes
            for i in 1...3 {
                try? await Task.sleep(for: .milliseconds(600))
                withAnimation(.spring(duration: 0.4)) {
                    visibleRecipes = i
                }
            }

            // Generate grocery list
            try? await Task.sleep(for: .milliseconds(500))
            phase = .generatingList
            withAnimation(.spring(duration: 0.5)) {
                showList = true
            }

            OnboardingAnalytics.track(.ahaMomentViewed, properties: ["variant": OnboardingVariant.valueFirst.rawValue])

            // Show CTA
            try? await Task.sleep(for: .milliseconds(600))
            phase = .complete
            withAnimation(.easeInOut(duration: 0.3)) {
                showCTA = true
            }
        }
    }
}
