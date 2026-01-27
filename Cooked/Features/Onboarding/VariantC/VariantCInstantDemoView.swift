//
//  VariantCInstantDemoView.swift
//  Cooked
//
//  Welcome screen with instant auto-playing demo of the menu → grocery list flow.
//

import SwiftUI

struct VariantCInstantDemoView: View {
    let onContinue: () -> Void

    @State private var phase: Int = 0

    private let demoRecipes = [
        ("Garlic Butter Shrimp", "flame.fill"),
        ("Caesar Salad", "leaf.fill"),
        ("Banana Pancakes", "frying.pan.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Demo phone mockup
            VStack(spacing: 0) {
                // Menu header
                HStack {
                    Text("This Week's Menu")
                        .font(.headline)
                    Spacer()
                    Text("3 recipes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider()

                // Recipes animate in
                VStack(spacing: 0) {
                    ForEach(0..<min(phase, 3), id: \.self) { i in
                        HStack(spacing: 12) {
                            Image(systemName: demoRecipes[i].1)
                                .foregroundStyle(.orange)
                                .frame(width: 32, height: 32)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(demoRecipes[i].0)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }

                if phase >= 4 {
                    Divider()

                    // Grocery list preview
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundStyle(.orange)
                        Text("Grocery list generated")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("12 items")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.08))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            .padding(.horizontal, 32)

            Spacer()

            // Title + CTA area
            VStack(spacing: 16) {
                if phase >= 5 {
                    VStack(spacing: 8) {
                        Text("Menu to grocery list\nin seconds")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Import recipes, plan your week, and shop smarter.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .transition(.opacity)

                    Button(action: onContinue) {
                        Text("Try it yourself")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .frame(minHeight: 160)
        }
        .onAppear { startDemo() }
    }

    private func startDemo() {
        Task { @MainActor in
            // Add recipes one by one
            for i in 1...3 {
                try? await Task.sleep(for: .milliseconds(500))
                withAnimation(.spring(duration: 0.4)) { phase = i }
            }

            // Generate grocery list
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.spring(duration: 0.4)) { phase = 4 }

            OnboardingAnalytics.track(.ahaMomentViewed, properties: ["variant": OnboardingVariant.instantGratification.rawValue])

            // Show CTA
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.easeInOut(duration: 0.3)) { phase = 5 }
        }
    }
}
