//
//  OnboardingAnalytics.swift
//  Cooked
//
//  Analytics event tracking for onboarding flows.
//

import Foundation

enum OnboardingAnalytics {
    enum Event: String {
        case onboardingStarted = "onboarding_started"
        case screenViewed = "onboarding_screen_viewed"
        case questionAnswered = "onboarding_question_answered"
        case ahaMomentViewed = "aha_moment_viewed"
        case paywallViewed = "paywall_viewed"
        case paywallDismissed = "paywall_dismissed"
        case trialStarted = "trial_started"
        case accountCreated = "account_created"
        case onboardingCompleted = "onboarding_completed"
        case onboardingAbandoned = "onboarding_abandoned"
    }

    static func track(_ event: Event, properties: [String: String] = [:]) {
        // TODO: Wire to PostHog in Phase 8
        #if DEBUG
        let propsString = properties.isEmpty ? "" : " \(properties)"
        print("[Onboarding Analytics] \(event.rawValue)\(propsString)")
        #endif
    }

    static func trackScreenView(screenNumber: Int, screenType: OnboardingScreenType, variant: OnboardingVariant) {
        track(.screenViewed, properties: [
            "screen_number": "\(screenNumber)",
            "screen_type": screenType.rawValue,
            "variant": variant.rawValue,
        ])
    }

    static func trackQuestionAnswered(questionId: String, answer: String) {
        track(.questionAnswered, properties: [
            "question_id": questionId,
            "answer": answer,
        ])
    }
}
