//
//  PaywallView.swift
//  Cooked
//
//  Simple paywall for Pro subscription upgrade.
//

import SwiftUI
import RevenueCat

/// Paywall view for upgrading to Pro subscription.
///
/// Displays Pro benefits and handles purchase/restore flows via RevenueCat.
struct PaywallView: View {
    @Environment(SubscriptionState.self) private var subscriptionState
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var isPurchasing = false
    @State private var error: Error?
    @State private var showError = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // MARK: Header Section

                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                    .accessibilityHidden(true)

                Text("Upgrade to Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Text(FreemiumLimits.proMonthlyPrice)
                    .font(.title2)
                    .foregroundStyle(.secondary)

                // MARK: Benefits Section

                VStack(alignment: .leading, spacing: 16) {
                    benefitRow(icon: "book.fill", text: "Unlimited recipes")
                    benefitRow(icon: "video.fill", text: "Unlimited video imports")
                    benefitRow(icon: "clock.arrow.circlepath", text: "Full menu history")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Pro benefits: Unlimited recipes, unlimited video imports, and full menu history")

                Spacer()

                // MARK: Purchase Section

                if let package = subscriptionState.currentOffering?.monthly {
                    Button {
                        Task { await purchase(package) }
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Subscribe for \(package.localizedPriceString)/month")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isPurchasing)
                    .padding(.horizontal)
                    .accessibilityLabel("Subscribe to Pro for \(package.localizedPriceString) per month")
                    .accessibilityHint("Double tap to start subscription")
                } else {
                    // Fallback if offerings not loaded
                    Button {
                        Task { await subscriptionState.loadOfferings() }
                    } label: {
                        Text("Loading...")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .accessibilityLabel("Loading subscription options")
                }

                Button("Restore Purchases") {
                    Task { await restore() }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
                .accessibilityHint("Restores previously purchased subscriptions")

                // MARK: Terms Section

                Text("Subscription auto-renews monthly. Cancel anytime.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(error?.localizedDescription ?? "An error occurred")
            }
        }
    }

    // MARK: - UI Components

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 24)
            Text(text)
                .font(.body)
            Spacer()
        }
    }

    // MARK: - Actions

    private func purchase(_ package: Package) async {
        isPurchasing = true
        do {
            try await subscriptionState.purchase(package)
            dismiss()
        } catch {
            self.error = error
            self.showError = true
        }
        isPurchasing = false
    }

    private func restore() async {
        isPurchasing = true
        do {
            try await subscriptionState.restorePurchases()
            if subscriptionState.isPro {
                dismiss()
            }
        } catch {
            self.error = error
            self.showError = true
        }
        isPurchasing = false
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
        .environment(SubscriptionState())
}
