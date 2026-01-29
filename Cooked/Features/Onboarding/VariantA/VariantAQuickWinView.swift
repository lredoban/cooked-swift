//
//  VariantAQuickWinView.swift
//  Cooked
//
//  Demonstrates the real-time list sharing feature with an animated demo.
//

import SwiftUI

struct VariantAQuickWinView: View {
    let onContinue: () -> Void

    @State private var phase: AnimationPhase = .idle
    @State private var checkedByYou: Set<Int> = []
    @State private var checkedByPartner: Set<Int> = []
    @State private var showSyncPulse = false
    @State private var showCTA = false

    private enum AnimationPhase {
        case idle, sharing, shopping, complete
    }

    private let groceryItems = [
        (0, "Chicken breast", "2 lbs", "you"),
        (1, "Bell peppers", "3", "partner"),
        (2, "Olive oil", "1 bottle", "you"),
        (3, "Onions", "2", "partner"),
        (4, "Garlic", "1 head", "you"),
        (5, "Rice", "1 bag", "partner"),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Header
            VStack(spacing: 8) {
                Text("Shop together, in real-time")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Text("Share your list with a partner and tackle the store together — every check syncs instantly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Two phones side by side
            HStack(spacing: 16) {
                // Your phone
                PhoneMockup(
                    title: "You",
                    icon: "person.fill",
                    accentColor: .orange
                ) {
                    GroceryListMockup(
                        items: groceryItems,
                        checkedByYou: checkedByYou,
                        checkedByPartner: checkedByPartner,
                        highlightShopper: "you",
                        showSyncPulse: showSyncPulse
                    )
                }

                // Partner's phone
                PhoneMockup(
                    title: "Partner",
                    icon: "person.fill",
                    accentColor: .green
                ) {
                    GroceryListMockup(
                        items: groceryItems,
                        checkedByYou: checkedByYou,
                        checkedByPartner: checkedByPartner,
                        highlightShopper: "partner",
                        showSyncPulse: showSyncPulse
                    )
                }
            }
            .padding(.horizontal, 20)

            // Sync indicator
            if phase == .shopping || phase == .complete {
                HStack(spacing: 8) {
                    SyncIcon(isAnimating: phase == .shopping)
                    Text("Syncing in real-time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            Spacer()

            // Completion message
            if phase == .complete {
                VStack(spacing: 4) {
                    Text("Done in half the time")
                        .font(.headline)
                        .foregroundStyle(.green)

                    Text("6 items checked off together")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            // CTA Button
            if showCTA {
                Button(action: onContinue) {
                    Text("Let's get cooking!")
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
        Task { @MainActor in
            // Brief pause before starting
            try? await Task.sleep(for: .milliseconds(500))

            withAnimation(.easeInOut(duration: 0.3)) {
                phase = .shopping
            }

            // Simulate alternating checks between you and partner
            let checkSequence: [(Int, String)] = [
                (0, "you"),      // Chicken breast
                (1, "partner"),  // Bell peppers
                (4, "you"),      // Garlic
                (3, "partner"),  // Onions
                (2, "you"),      // Olive oil
                (5, "partner"),  // Rice
            ]

            for (index, shopper) in checkSequence {
                try? await Task.sleep(for: .milliseconds(700))

                withAnimation(.spring(duration: 0.3)) {
                    showSyncPulse = true
                    if shopper == "you" {
                        checkedByYou.insert(index)
                    } else {
                        checkedByPartner.insert(index)
                    }
                }

                // Brief pulse effect
                try? await Task.sleep(for: .milliseconds(200))
                withAnimation(.easeOut(duration: 0.2)) {
                    showSyncPulse = false
                }
            }

            // Complete
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.spring(duration: 0.4)) {
                phase = .complete
            }

            // Show CTA
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.easeInOut(duration: 0.3)) {
                showCTA = true
            }
        }
    }
}

// MARK: - Phone Mockup

private struct PhoneMockup<Content: View>: View {
    let title: String
    let icon: String
    let accentColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 8) {
            // Label
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(accentColor)

            // Phone frame
            VStack(spacing: 0) {
                // Status bar
                HStack {
                    Text("9:41")
                        .font(.system(size: 9, weight: .semibold))
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: "wifi")
                        Image(systemName: "battery.100")
                    }
                    .font(.system(size: 8))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.top, 4)
                .padding(.bottom, 2)

                // Content
                content
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

// MARK: - Grocery List Mockup

private struct GroceryListMockup: View {
    let items: [(Int, String, String, String)]
    let checkedByYou: Set<Int>
    let checkedByPartner: Set<Int>
    let highlightShopper: String
    let showSyncPulse: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checklist")
                    .foregroundStyle(.orange)
                    .font(.system(size: 10))
                Text("Grocery List")
                    .font(.system(size: 10, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))

            // Items
            VStack(spacing: 0) {
                ForEach(items, id: \.0) { item in
                    let isChecked = checkedByYou.contains(item.0) || checkedByPartner.contains(item.0)
                    let wasCheckedByHighlighted = (highlightShopper == "you" && checkedByYou.contains(item.0)) ||
                                                   (highlightShopper == "partner" && checkedByPartner.contains(item.0))
                    let wasCheckedByOther = (highlightShopper == "you" && checkedByPartner.contains(item.0)) ||
                                            (highlightShopper == "partner" && checkedByYou.contains(item.0))

                    HStack(spacing: 6) {
                        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 10))
                            .foregroundStyle(
                                isChecked
                                    ? (wasCheckedByHighlighted ? .green : .green.opacity(0.6))
                                    : Color(.systemGray4)
                            )

                        VStack(alignment: .leading, spacing: 0) {
                            Text(item.1)
                                .font(.system(size: 9))
                                .strikethrough(isChecked)
                                .foregroundStyle(isChecked ? .secondary : .primary)
                            Text(item.2)
                                .font(.system(size: 7))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // Show sync indicator for items checked by the other person
                        if wasCheckedByOther && showSyncPulse {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 7))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        wasCheckedByHighlighted && showSyncPulse
                            ? Color.green.opacity(0.1)
                            : Color.clear
                    )

                    if item.0 != items.last?.0 {
                        Divider()
                            .padding(.leading, 24)
                    }
                }
            }
        }
        .frame(height: 180)
    }
}

// MARK: - Sync Icon (iOS 17 compatible)

private struct SyncIcon: View {
    let isAnimating: Bool
    @State private var rotation: Double = 0

    var body: some View {
        Image(systemName: "arrow.triangle.2.circlepath")
            .foregroundStyle(.green)
            .rotationEffect(.degrees(rotation))
            .onChange(of: isAnimating, initial: true) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        rotation = 0
                    }
                }
            }
    }
}
