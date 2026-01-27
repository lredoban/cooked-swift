//
//  VariantAOnboardingView.swift
//  Cooked
//
//  Variant A: "Value First" (Duolingo Model)
//  Flow: Welcome → Goal → Frequency → Magic Demo → Quick Win → Paywall → Account
//

import SwiftUI

struct VariantAOnboardingView: View {
    @Environment(OnboardingState.self) private var onboardingState

    @State private var screen: Int = 0
    private let totalScreens = 7
    private let variant = OnboardingVariant.valueFirst

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch screen {
            case 0: welcomeScreen
            case 1: goalQuestionScreen
            case 2: frequencyQuestionScreen
            case 3: magicMomentScreen
            case 4: quickWinScreen
            case 5: paywallScreen
            case 6: accountScreen
            default: EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
    }

    // MARK: - Screen 1: Welcome

    private var welcomeScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("Plan meals.\nCook more.\nStress less.")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Build your weekly menu in minutes and never wonder \"what's for dinner\" again.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            primaryButton("Get Started") {
                advance(screenType: .welcome)
            }
        }
        .padding(24)
        .onAppear { trackScreen(0, type: .welcome) }
    }

    // MARK: - Screen 2: Goal Question

    private var goalQuestionScreen: some View {
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
        .onAppear { trackScreen(1, type: .personalizationQuestion) }
    }

    // MARK: - Screen 3: Frequency Question

    private var frequencyQuestionScreen: some View {
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
        .onAppear { trackScreen(2, type: .personalizationQuestion) }
    }

    // MARK: - Screen 4: Magic Moment Demo

    private var magicMomentScreen: some View {
        VariantAMagicMomentView {
            advance(screenType: .magicMoment)
        }
        .onAppear { trackScreen(3, type: .magicMoment) }
    }

    // MARK: - Screen 5: Quick Win

    private var quickWinScreen: some View {
        VariantAQuickWinView {
            advance(screenType: .quickWin)
        }
        .onAppear { trackScreen(4, type: .quickWin) }
    }

    // MARK: - Screen 6: Paywall

    private var paywallScreen: some View {
        OnboardingPaywallView(
            headline: onboardingState.personalizedHeadline,
            subheadline: onboardingState.personalizedSubheadline,
            variant: variant,
            onContinue: { advance(screenType: .paywall) },
            onSkip: { advance(screenType: .paywall) }
        )
        .onAppear { trackScreen(5, type: .paywall) }
    }

    // MARK: - Screen 7: Account

    private var accountScreen: some View {
        VariantAAccountView {
            onboardingState.completeOnboarding()
        }
        .onAppear { trackScreen(6, type: .accountCreation) }
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

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
