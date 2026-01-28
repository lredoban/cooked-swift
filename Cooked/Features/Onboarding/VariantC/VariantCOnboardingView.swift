//
//  VariantCOnboardingView.swift
//  Cooked
//
//  Variant C: "Instant Gratification" (PhotoRoom Model)
//  Flow: Welcome+Demo → Quick Win → Paywall → Goal → Frequency → Feature Showcase → Soft Gate+Account
//

import SwiftUI

struct VariantCOnboardingView: View {
    @Environment(OnboardingState.self) private var onboardingState

    @State private var screen: Int = 0
    private let variant = OnboardingVariant.instantGratification

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch screen {
            case 0: welcomeDemoScreen
            case 1: quickWinScreen
            case 2: earlyPaywallScreen
            case 3: goalScreen
            case 4: frequencyScreen
            case 5: featureShowcaseScreen
            default: EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
    }

    // MARK: - Screen 1: Welcome + Instant Demo

    private var welcomeDemoScreen: some View {
        VariantCInstantDemoView {
            advance(screenType: .welcome)
        }
        .onAppear { trackScreen(0, type: .welcome) }
    }

    // MARK: - Screen 2: Quick Win

    private var quickWinScreen: some View {
        VariantAQuickWinView {
            advance(screenType: .quickWin)
        }
        .onAppear { trackScreen(1, type: .quickWin) }
    }

    // MARK: - Screen 3: Early Paywall

    private var earlyPaywallScreen: some View {
        OnboardingPaywallView(
            headline: "Unlock unlimited cooking",
            subheadline: "Plan meals, import recipes, and generate grocery lists — all in one app.",
            variant: variant,
            onContinue: { advance(screenType: .paywall) },
            onSkip: { advance(screenType: .paywall) }
        )
        .onAppear { trackScreen(2, type: .paywall) }
    }

    // MARK: - Screen 4: Goal Question

    private var goalScreen: some View {
        VStack(spacing: 24) {
            OnboardingProgressBar(current: 0, total: 2)
                .padding(.top, 16)

            Text("What's your #1 cooking goal?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 12) {
                ForEach(CookingGoal.allCases) { goal in
                    OnboardingOptionCard(
                        icon: goal.icon,
                        title: goal.title,
                        subtitle: goal.subtitle,
                        isSelected: onboardingState.personalization.cookingGoal == goal
                    ) {
                        onboardingState.personalization.cookingGoal = goal
                        OnboardingAnalytics.trackQuestionAnswered(questionId: "cooking_goal", answer: goal.rawValue)
                        advanceAfterDelay(screenType: .personalizationQuestion)
                    }
                }
            }

            Spacer()
        }
        .padding(24)
        .onAppear { trackScreen(3, type: .personalizationQuestion) }
    }

    // MARK: - Screen 5: Frequency Question

    private var frequencyScreen: some View {
        VStack(spacing: 24) {
            OnboardingProgressBar(current: 1, total: 2)
                .padding(.top, 16)

            Text("How often do you cook?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 12) {
                ForEach(CookingFrequency.allCases) { freq in
                    OnboardingOptionCard(
                        icon: freq.icon,
                        title: freq.title,
                        isSelected: onboardingState.personalization.cookingFrequency == freq
                    ) {
                        onboardingState.personalization.cookingFrequency = freq
                        OnboardingAnalytics.trackQuestionAnswered(questionId: "cooking_frequency", answer: freq.rawValue)
                        advanceAfterDelay(screenType: .personalizationQuestion)
                    }
                }
            }

            Spacer()
        }
        .padding(24)
        .onAppear { trackScreen(4, type: .personalizationQuestion) }
    }

    // MARK: - Screen 6: Feature Showcase

    private var featureShowcaseScreen: some View {
        VariantCFeatureShowcaseView {
            onboardingState.completeOnboarding()
        }
        .onAppear { trackScreen(5, type: .featureShowcase) }
    }

    // MARK: - Helpers

    private func advance(screenType: OnboardingScreenType) {
        screen += 1
    }

    private func advanceAfterDelay(screenType: OnboardingScreenType) {
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            await MainActor.run { screen += 1 }
        }
    }

    private func trackScreen(_ number: Int, type: OnboardingScreenType) {
        OnboardingAnalytics.trackScreenView(screenNumber: number, screenType: type, variant: variant)
    }
}
