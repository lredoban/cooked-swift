//
//  FreemiumLimits.swift
//  Cooked
//
//  Centralized configuration for freemium tier limits.
//  Edit these values during development to test different scenarios.
//

import Foundation

enum FreemiumLimits {
    // MARK: - Recipe Limits

    /// Maximum recipes for free tier (prod: 15)
    static let freeRecipeLimit: Int = 4

    /// Maximum video imports per month for free tier (prod: 5)
    static let freeVideoImportsPerMonth: Int = 2

    // MARK: - Menu Limits

    /// Maximum menu history entries for free tier (prod: 3)
    static let freeMenuHistoryLimit: Int = 3

    // MARK: - Pro Pricing (for display only)

    static let proMonthlyPrice: String = "$4.99/mo"
    static let proDescription: String = "Unlimited recipes, video imports, and menu history"
}
