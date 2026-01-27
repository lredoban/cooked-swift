//
//  OnboardingModels.swift
//  Cooked
//
//  Data models for onboarding flows and personalization.
//

import Foundation

// MARK: - Onboarding Variant

enum OnboardingVariant: String, CaseIterable, Sendable {
    case valueFirst = "value_first"        // Variant A
    case investmentHeavy = "investment_heavy" // Variant B
    case instantGratification = "instant_gratification" // Variant C
}

// MARK: - Personalization Questions

enum CookingGoal: String, CaseIterable, Identifiable, Sendable {
    case saveTime = "save_time"
    case eatHealthier = "eat_healthier"
    case saveMoney = "save_money"
    case tryNewRecipes = "try_new_recipes"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .saveTime: return "Save Time"
        case .eatHealthier: return "Eat Healthier"
        case .saveMoney: return "Save Money"
        case .tryNewRecipes: return "Try New Recipes"
        }
    }

    var subtitle: String {
        switch self {
        case .saveTime: return "Less planning, more cooking"
        case .eatHealthier: return "Build better food habits"
        case .saveMoney: return "Reduce takeout & waste"
        case .tryNewRecipes: return "Expand your cooking skills"
        }
    }

    var icon: String {
        switch self {
        case .saveTime: return "clock.fill"
        case .eatHealthier: return "leaf.fill"
        case .saveMoney: return "dollarsign.circle.fill"
        case .tryNewRecipes: return "sparkles"
        }
    }
}

enum CookingFrequency: String, CaseIterable, Identifiable, Sendable {
    case rarely = "rarely"
    case fewTimesWeek = "few_times_week"
    case mostNights = "most_nights"
    case everyDay = "every_day"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rarely: return "1-2 times a week"
        case .fewTimesWeek: return "3-4 times a week"
        case .mostNights: return "Most nights"
        case .everyDay: return "Every day"
        }
    }

    var icon: String {
        switch self {
        case .rarely: return "flame"
        case .fewTimesWeek: return "flame.fill"
        case .mostNights: return "frying.pan"
        case .everyDay: return "frying.pan.fill"
        }
    }
}

enum HouseholdSize: String, CaseIterable, Identifiable, Sendable {
    case justMe = "just_me"
    case couple = "couple"
    case smallFamily = "small_family"
    case largeFamily = "large_family"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .justMe: return "Just me"
        case .couple: return "2 people"
        case .smallFamily: return "3-4 people"
        case .largeFamily: return "5+ people"
        }
    }

    var icon: String {
        switch self {
        case .justMe: return "person.fill"
        case .couple: return "person.2.fill"
        case .smallFamily: return "person.3.fill"
        case .largeFamily: return "person.3.sequence.fill"
        }
    }
}

enum RecipeSource: String, CaseIterable, Identifiable, Sendable {
    case socialMedia = "social_media"
    case websites = "websites"
    case cookbooks = "cookbooks"
    case friendsFamily = "friends_family"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .socialMedia: return "Social Media"
        case .websites: return "Recipe Websites"
        case .cookbooks: return "Cookbooks"
        case .friendsFamily: return "Friends & Family"
        }
    }

    var icon: String {
        switch self {
        case .socialMedia: return "play.rectangle.fill"
        case .websites: return "globe"
        case .cookbooks: return "book.closed.fill"
        case .friendsFamily: return "heart.fill"
        }
    }
}

// MARK: - Personalization Data

struct OnboardingPersonalization: Sendable {
    var cookingGoal: CookingGoal?
    var cookingFrequency: CookingFrequency?
    var householdSize: HouseholdSize?
    var recipeSource: RecipeSource?
}

// MARK: - Screen Type (for analytics)

enum OnboardingScreenType: String, Sendable {
    case welcome
    case personalizationQuestion = "personalization_question"
    case magicMoment = "magic_moment"
    case quickWin = "quick_win"
    case paywall
    case accountCreation = "account_creation"
    case socialProof = "social_proof"
    case featureShowcase = "feature_showcase"
    case softGate = "soft_gate"
}
