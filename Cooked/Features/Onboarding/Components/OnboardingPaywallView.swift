//
//  OnboardingPaywallView.swift
//  Cooked
//
//  Paywall screen used within onboarding flows. Supports personalization.
//

import SwiftUI
import RevenueCat

struct OnboardingPaywallView: View {
    @Environment(SubscriptionState.self) private var subscriptionState
    let headline: String
    let subheadline: String
    let variant: OnboardingVariant
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var isPurchasing = false
    @State private var error: Error?
    @State private var showError = false
    @State private var selectedPlan: PlanOption = .annual

    private enum PlanOption {
        case annual, monthly
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Header
                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.orange)
                            .accessibilityHidden(true)

                        Text(headline)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text(subheadline)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 24)

                    // MARK: Benefits
                    VStack(alignment: .leading, spacing: 14) {
                        benefitRow(icon: "book.fill", text: "Unlimited recipes")
                        benefitRow(icon: "video.fill", text: "Unlimited video imports")
                        benefitRow(icon: "clock.arrow.circlepath", text: "Full menu history")
                        benefitRow(icon: "list.bullet", text: "Smart grocery lists")
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)

                    // MARK: Pricing
                    VStack(spacing: 12) {
                        pricingCard(
                            title: "Annual",
                            price: "$2.49/mo",
                            detail: "Billed $29.99/year",
                            badge: "Save 58%",
                            isSelected: selectedPlan == .annual
                        ) {
                            selectedPlan = .annual
                        }

                        pricingCard(
                            title: "Monthly",
                            price: "$4.99/mo",
                            detail: "Billed monthly",
                            badge: nil,
                            isSelected: selectedPlan == .monthly
                        ) {
                            selectedPlan = .monthly
                        }
                    }
                    .padding(.horizontal, 24)

                    // MARK: Trial Timeline
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            timelineDot(label: "Today", sublabel: "Full access", isActive: true)
                            timelineLine()
                            timelineDot(label: "Day 5", sublabel: "Reminder", isActive: false)
                            timelineLine()
                            timelineDot(label: "Day 7", sublabel: "Billing", isActive: false)
                        }
                    }
                    .padding(.horizontal, 24)

                    // MARK: Trust
                    Text("Cancel anytime during your free trial. No charge until Day 7.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)
            }

            // MARK: CTA
            VStack(spacing: 12) {
                Button {
                    Task { await startTrial() }
                } label: {
                    HStack {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Start free trial")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isPurchasing)
                .accessibilityLabel("Start 7-day free trial")

                Button("Not now") {
                    OnboardingAnalytics.track(.paywallDismissed, properties: ["variant": variant.rawValue])
                    onSkip()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Skip free trial")

                Button("Restore Purchases") {
                    Task { await restore() }
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .padding(.top, 8)
            .background(Color(.systemBackground))
        }
        .onAppear {
            OnboardingAnalytics.track(.paywallViewed, properties: ["variant": variant.rawValue])
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(error?.localizedDescription ?? "Something went wrong")
        }
    }

    // MARK: - Components

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

    private func pricingCard(title: String, price: String, detail: String, badge: String?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                    }
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(price)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding(16)
            .background(isSelected ? Color.orange.opacity(0.08) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) plan, \(price), \(detail)\(badge.map { ", \($0)" } ?? "")")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func timelineDot(label: String, sublabel: String, isActive: Bool) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.orange : Color(.systemGray4))
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
            Text(sublabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func timelineLine() -> some View {
        Rectangle()
            .fill(Color(.systemGray4))
            .frame(height: 1)
            .frame(maxWidth: 40)
            .offset(y: -12)
    }

    // MARK: - Actions

    private func startTrial() async {
        let package: Package?
        switch selectedPlan {
        case .annual:
            package = subscriptionState.currentOffering?.annual
        case .monthly:
            package = subscriptionState.currentOffering?.monthly
        }

        guard let package else { return }

        isPurchasing = true
        do {
            try await subscriptionState.purchase(package)
            OnboardingAnalytics.track(.trialStarted, properties: ["variant": variant.rawValue, "plan": selectedPlan == .annual ? "annual" : "monthly"])
            onContinue()
        } catch {
            self.error = error
            showError = true
        }
        isPurchasing = false
    }

    private func restore() async {
        isPurchasing = true
        do {
            try await subscriptionState.restorePurchases()
            if subscriptionState.isPro {
                onContinue()
            }
        } catch {
            self.error = error
            showError = true
        }
        isPurchasing = false
    }
}
