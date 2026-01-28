//
//  OnboardingRootView.swift
//  Cooked
//
//  Root view that displays the active onboarding variant.
//

import SwiftUI

struct OnboardingRootView: View {
    @Environment(OnboardingState.self) private var onboardingState

    var body: some View {
        switch onboardingState.activeVariant {
        case .valueFirst:
            VariantAOnboardingView()
        case .investmentHeavy:
            VariantBOnboardingView()
        case .instantGratification:
            VariantCOnboardingView()
        }
    }
}
