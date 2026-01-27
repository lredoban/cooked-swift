//
//  VariantCFeatureShowcaseView.swift
//  Cooked
//
//  Shows secondary features and premium capabilities.
//

import SwiftUI

struct VariantCFeatureShowcaseView: View {
    let onContinue: () -> Void

    @State private var currentFeature: Int = 0

    private let features: [(icon: String, title: String, description: String, isPro: Bool)] = [
        ("video.fill", "Import from videos", "Paste a TikTok or YouTube link — we extract the recipe automatically.", true),
        ("globe", "Import from any website", "Save recipes from your favorite food blogs in one tap.", false),
        ("clock.arrow.circlepath", "Menu history", "Reuse past menus when you find meals your family loves.", true),
        ("list.bullet", "Smart grocery lists", "Auto-generated, organized by aisle, and shareable.", false),
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Here's what else you can do")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .accessibilityAddTraits(.isHeader)

            TabView(selection: $currentFeature) {
                ForEach(0..<features.count, id: \.self) { index in
                    featureCard(features[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 280)

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func featureCard(_ feature: (icon: String, title: String, description: String, isPro: Bool)) -> some View {
        VStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.system(size: 44))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text(feature.title)
                        .font(.headline)
                    if feature.isPro {
                        Text("PRO")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }

                Text(feature.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
    }
}
