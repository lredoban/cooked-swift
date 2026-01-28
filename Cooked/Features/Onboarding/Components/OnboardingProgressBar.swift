//
//  OnboardingProgressBar.swift
//  Cooked
//
//  Progress indicator for onboarding question screens.
//

import SwiftUI

struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.orange : Color(.systemGray4))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.25), value: current)
        .accessibilityLabel("Step \(current + 1) of \(total)")
    }
}
