//
//  SubscriptionState.swift
//  Cooked
//
//  RevenueCat integration and subscription state management.
//

import Foundation
import RevenueCat

@Observable
final class SubscriptionState {
    // MARK: - Subscription Status

    private(set) var isPro: Bool = false
    var isLoading: Bool = false
    var error: Error?

    // Current offering for paywall
    private(set) var currentOffering: Offering?

    // MARK: - Paywall State

    var isShowingPaywall: Bool = false

    // MARK: - Limit Check Helpers

    func canAddRecipe(currentCount: Int) -> Bool {
        isPro || currentCount < FreemiumLimits.freeRecipeLimit
    }

    func canImportVideo(monthlyCount: Int) -> Bool {
        isPro || monthlyCount < FreemiumLimits.freeVideoImportsPerMonth
    }

    func menuHistoryLimit() -> Int? {
        isPro ? nil : FreemiumLimits.freeMenuHistoryLimit
    }

    func recipesRemaining(currentCount: Int) -> Int {
        max(0, FreemiumLimits.freeRecipeLimit - currentCount)
    }

    func videoImportsRemaining(monthlyCount: Int) -> Int {
        max(0, FreemiumLimits.freeVideoImportsPerMonth - monthlyCount)
    }

    // MARK: - RevenueCat Configuration

    func configure(userId: String) async {
        #if DEBUG
        Purchases.logLevel = .debug
        #endif

        Purchases.configure(withAPIKey: AppConfig.revenueCatAPIKey, appUserID: userId)

        await refreshSubscriptionStatus()
        await loadOfferings()
    }

    // MARK: - Subscription Management

    func refreshSubscriptionStatus() async {
        isLoading = true
        error = nil

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPro = customerInfo.entitlements["pro"]?.isActive == true
        } catch {
            self.error = error
            print("[Cooked] Failed to fetch customer info: \(error)")
        }

        isLoading = false
    }

    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch {
            self.error = error
            print("[Cooked] Failed to load offerings: \(error)")
        }
    }

    func purchase(_ package: Package) async throws {
        isLoading = true
        error = nil

        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPro = result.customerInfo.entitlements["pro"]?.isActive == true
            isLoading = false
        } catch {
            isLoading = false
            self.error = error
            throw error
        }
    }

    func restorePurchases() async throws {
        isLoading = true
        error = nil

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isPro = customerInfo.entitlements["pro"]?.isActive == true
            isLoading = false
        } catch {
            isLoading = false
            self.error = error
            throw error
        }
    }

    // MARK: - Paywall Actions

    func showPaywall() {
        isShowingPaywall = true
    }

    func hidePaywall() {
        isShowingPaywall = false
    }
}
