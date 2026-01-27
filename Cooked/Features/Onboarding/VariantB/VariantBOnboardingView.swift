//
//  VariantBOnboardingView.swift
//  Cooked
//
//  Variant B: "Investment Heavy" (Noom Model)
//  Flow: Welcome+Promise → Goal → Frequency → Household → Source → Building+Paywall → Account
//

import SwiftUI

struct VariantBOnboardingView: View {
    @Environment(OnboardingState.self) private var onboardingState

    @State private var screen: Int = 0
    private let variant = OnboardingVariant.investmentHeavy

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            switch screen {
            case 0: welcomeScreen
            case 1: goalScreen
            case 2: frequencyScreen
            case 3: householdScreen
            case 4: sourceScreen
            case 5: buildingAndPaywallScreen
            case 6: accountScreen
            default: EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
    }

    // MARK: - Screen 1: Welcome + Promise

    private var welcomeScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("Your personalized\nmeal plan awaits")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text("Answer a few quick questions so we can build the perfect cooking plan for you.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            Button {
                advance(screenType: .welcome)
            } label: {
                Text("Get my personalized plan")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(24)
        .onAppear { trackScreen(0, type: .welcome) }
    }

    // MARK: - Screen 2: Goal (1 of 4)

    private var goalScreen: some View {
        questionScreen(
            progress: 0,
            total: 4,
            question: "What's your main cooking goal?",
            screenNumber: 1
        ) {
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
    }

    // MARK: - Screen 3: Frequency (2 of 4)

    private var frequencyScreen: some View {
        questionScreen(
            progress: 1,
            total: 4,
            question: "How often do you cook at home?",
            screenNumber: 2
        ) {
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
    }

    // MARK: - Screen 4: Household (3 of 4)

    private var householdScreen: some View {
        questionScreen(
            progress: 2,
            total: 4,
            question: "How many people are you cooking for?",
            screenNumber: 3
        ) {
            ForEach(HouseholdSize.allCases) { size in
                OnboardingOptionCard(
                    icon: size.icon,
                    title: size.title,
                    isSelected: onboardingState.personalization.householdSize == size
                ) {
                    onboardingState.personalization.householdSize = size
                    OnboardingAnalytics.trackQuestionAnswered(questionId: "household_size", answer: size.rawValue)
                    advanceAfterDelay(screenType: .personalizationQuestion)
                }
            }
        }
    }

    // MARK: - Screen 5: Recipe Source (4 of 4)

    private var sourceScreen: some View {
        questionScreen(
            progress: 3,
            total: 4,
            question: "Where do you find recipes?",
            screenNumber: 4
        ) {
            ForEach(RecipeSource.allCases) { source in
                OnboardingOptionCard(
                    icon: source.icon,
                    title: source.title,
                    isSelected: onboardingState.personalization.recipeSource == source
                ) {
                    onboardingState.personalization.recipeSource = source
                    OnboardingAnalytics.trackQuestionAnswered(questionId: "recipe_source", answer: source.rawValue)
                    advanceAfterDelay(screenType: .personalizationQuestion)
                }
            }
        }
    }

    // MARK: - Screen 6: Building Plan + Paywall

    private var buildingAndPaywallScreen: some View {
        VariantBBuildingPaywallView(
            onboardingState: onboardingState,
            variant: variant,
            onContinue: { advance(screenType: .paywall) },
            onSkip: { advance(screenType: .paywall) }
        )
        .onAppear { trackScreen(5, type: .magicMoment) }
    }

    // MARK: - Screen 7: Account

    private var accountScreen: some View {
        VariantAAccountView {
            onboardingState.completeOnboarding()
        }
        .onAppear { trackScreen(6, type: .accountCreation) }
    }

    // MARK: - Helpers

    private func questionScreen<Content: View>(
        progress: Int,
        total: Int,
        question: String,
        screenNumber: Int,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(spacing: 24) {
            OnboardingProgressBar(current: progress, total: total)
                .padding(.top, 16)

            Text(question)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 12) {
                content()
            }

            Spacer()
        }
        .padding(24)
        .onAppear { trackScreen(screenNumber, type: .personalizationQuestion) }
    }

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
