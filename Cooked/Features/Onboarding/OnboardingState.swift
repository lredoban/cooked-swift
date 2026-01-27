//
//  OnboardingState.swift
//  Cooked
//
//  Central state management for onboarding flows.
//

import Foundation

@Observable
final class OnboardingState {
    // MARK: - Onboarding Status

    private(set) var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    // MARK: - Active Variant

    private(set) var activeVariant: OnboardingVariant

    // MARK: - Personalization

    var personalization = OnboardingPersonalization()

    // MARK: - Flow State

    var currentScreen: Int = 0
    var isOnboardingActive: Bool = false

    // MARK: - Init

    init() {
        // Default to Variant A; change to run different variants
        self.activeVariant = .valueFirst
    }

    // MARK: - Actions

    func startOnboarding(variant: OnboardingVariant? = nil) {
        if let variant { activeVariant = variant }
        currentScreen = 0
        isOnboardingActive = true
        OnboardingAnalytics.track(.onboardingStarted, properties: ["variant": activeVariant.rawValue])
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        isOnboardingActive = false
        OnboardingAnalytics.track(.onboardingCompleted, properties: [
            "variant": activeVariant.rawValue,
            "goal": personalization.cookingGoal?.rawValue ?? "none",
        ])
    }

    func advanceScreen() {
        currentScreen += 1
    }

    func reset() {
        hasCompletedOnboarding = false
        personalization = OnboardingPersonalization()
        currentScreen = 0
    }

    // MARK: - Personalized Copy

    var personalizedHeadline: String {
        guard let goal = personalization.cookingGoal else {
            return "Unlock your full cooking potential"
        }
        switch goal {
        case .saveTime:
            return "Your time-saving meal plan is ready"
        case .eatHealthier:
            return "Your healthy eating plan is ready"
        case .saveMoney:
            return "Your money-saving meal plan is ready"
        case .tryNewRecipes:
            return "Your personalized recipe plan is ready"
        }
    }

    var personalizedSubheadline: String {
        guard let goal = personalization.cookingGoal else {
            return "Get unlimited access to everything Cooked offers."
        }
        switch goal {
        case .saveTime:
            return "Spend less time planning and more time enjoying meals."
        case .eatHealthier:
            return "Build a weekly menu that supports your health goals."
        case .saveMoney:
            return "Plan your meals, reduce waste, and skip the takeout."
        case .tryNewRecipes:
            return "Discover and organize new recipes every week."
        }
    }
}
