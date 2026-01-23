//
//  ServiceTests.swift
//  CookedTests
//
//  Service layer tests focusing on error types and validation logic.
//  Note: Full integration tests require a test Supabase instance.
//

import Testing
import Foundation
@testable import Cooked

// MARK: - RecipeServiceError Tests

struct RecipeServiceErrorTests {

    @Test("Error descriptions are human readable")
    func errorDescriptionsAreReadable() {
        let extractionError = RecipeServiceError.extractionFailed("Invalid format")
        let networkError = RecipeServiceError.networkError
        let invalidURLError = RecipeServiceError.invalidURL
        let unauthorizedError = RecipeServiceError.unauthorized
        let saveError = RecipeServiceError.saveFailed("Database error")
        let deleteError = RecipeServiceError.deleteFailed("Not found")

        #expect(extractionError.errorDescription == "Failed to extract recipe: Invalid format")
        #expect(networkError.errorDescription == "Network connection failed")
        #expect(invalidURLError.errorDescription == "Invalid URL format")
        #expect(unauthorizedError.errorDescription == "Please sign in to continue")
        #expect(saveError.errorDescription == "Failed to save recipe: Database error")
        #expect(deleteError.errorDescription == "Failed to delete recipe: Not found")
    }

    @Test("Errors conform to LocalizedError")
    func errorsConformToLocalizedError() {
        let error: LocalizedError = RecipeServiceError.networkError
        #expect(error.errorDescription != nil)
    }
}

// MARK: - MenuServiceError Tests

struct MenuServiceErrorTests {

    @Test("Error descriptions are human readable")
    func errorDescriptionsAreReadable() {
        let unauthorizedError = MenuServiceError.unauthorized
        let notFoundError = MenuServiceError.menuNotFound
        let createError = MenuServiceError.createFailed("Database error")
        let updateError = MenuServiceError.updateFailed("Invalid status")
        let deleteError = MenuServiceError.deleteFailed("Foreign key constraint")
        let addRecipeError = MenuServiceError.addRecipeFailed("Recipe not found")

        #expect(unauthorizedError.errorDescription == "Please sign in to continue")
        #expect(notFoundError.errorDescription == "Menu not found")
        #expect(createError.errorDescription == "Failed to create menu: Database error")
        #expect(updateError.errorDescription == "Failed to update menu: Invalid status")
        #expect(deleteError.errorDescription == "Failed to delete menu: Foreign key constraint")
        #expect(addRecipeError.errorDescription == "Failed to add recipe: Recipe not found")
    }

    @Test("Errors conform to LocalizedError")
    func errorsConformToLocalizedError() {
        let error: LocalizedError = MenuServiceError.unauthorized
        #expect(error.errorDescription != nil)
    }
}

// MARK: - GroceryListServiceError Tests

struct GroceryListServiceErrorTests {

    @Test("Error descriptions are human readable")
    func errorDescriptionsAreReadable() {
        let unauthorizedError = GroceryListServiceError.unauthorized
        let notFoundError = GroceryListServiceError.listNotFound
        let createError = GroceryListServiceError.createFailed("Database error")
        let updateError = GroceryListServiceError.updateFailed("Invalid data")
        let deleteError = GroceryListServiceError.deleteFailed("Not found")

        #expect(unauthorizedError.errorDescription == "Please sign in to continue")
        #expect(notFoundError.errorDescription == "Grocery list not found")
        #expect(createError.errorDescription == "Failed to create grocery list: Database error")
        #expect(updateError.errorDescription == "Failed to update grocery list: Invalid data")
        #expect(deleteError.errorDescription == "Failed to delete grocery list: Not found")
    }
}

// MARK: - FreemiumLimits Tests

struct FreemiumLimitsTests {

    @Test("Free tier limits are configured")
    func freeTierLimitsConfigured() {
        // These values may differ between dev and prod
        #expect(FreemiumLimits.freeRecipeLimit > 0)
        #expect(FreemiumLimits.freeVideoImportsPerMonth > 0)
        #expect(FreemiumLimits.freeMenuHistoryLimit > 0)
    }

    @Test("Pro pricing is configured")
    func proPricingConfigured() {
        #expect(FreemiumLimits.proMonthlyPrice.contains("$"))
        #expect(!FreemiumLimits.proDescription.isEmpty)
    }

    @Test("Limit values are reasonable")
    func limitValuesAreReasonable() {
        // Limits should be positive
        #expect(FreemiumLimits.freeRecipeLimit >= 1)
        #expect(FreemiumLimits.freeVideoImportsPerMonth >= 1)
        #expect(FreemiumLimits.freeMenuHistoryLimit >= 1)

        // Limits should not be excessive for free tier
        #expect(FreemiumLimits.freeRecipeLimit <= 100)
        #expect(FreemiumLimits.freeVideoImportsPerMonth <= 50)
        #expect(FreemiumLimits.freeMenuHistoryLimit <= 50)
    }
}

// MARK: - AppConfig Tests

struct AppConfigTests {

    @Test("Backend URL is configured")
    func backendURLIsConfigured() {
        // AppConfig should have a valid URL
        let url = AppConfig.backendURL
        #expect(url.scheme == "http" || url.scheme == "https")
    }

    @Test("Supabase URL is configured")
    func supabaseURLIsConfigured() {
        let url = AppConfig.supabaseURL
        #expect(url.scheme == "http" || url.scheme == "https")
    }
}

// MARK: - URL Validation Tests

struct URLValidationTests {

    @Test("Valid URLs are accepted")
    func validURLsAccepted() {
        let validURLs = [
            "https://example.com/recipe",
            "https://www.tiktok.com/@user/video/123",
            "https://instagram.com/p/abc123",
            "https://youtube.com/watch?v=abc123",
            "http://localhost:3000/test"
        ]

        for urlString in validURLs {
            #expect(URL(string: urlString) != nil, "Should parse: \(urlString)")
        }
    }

    @Test("Invalid URLs are rejected")
    func invalidURLsRejected() {
        let invalidURLs = [
            "not a url",
            "://missing-scheme.com",
            ""
        ]

        for urlString in invalidURLs {
            let url = URL(string: urlString)
            #expect(url == nil || url?.scheme == nil, "Should reject: \(urlString)")
        }
    }
}

// MARK: - ExtractRequest Tests

struct ExtractRequestTests {

    @Test("ExtractRequest encodes correctly")
    func extractRequestEncodesCorrectly() throws {
        let request = ExtractRequest(url: "https://example.com", sourceType: "video")

        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["url"] as? String == "https://example.com")
        #expect(json?["sourceType"] as? String == "video")
    }

    @Test("ExtractRequest encodes with nil sourceType")
    func extractRequestEncodesWithNilSourceType() throws {
        let request = ExtractRequest(url: "https://example.com", sourceType: nil)

        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(json?["url"] as? String == "https://example.com")
        // sourceType should be absent or null
    }
}
