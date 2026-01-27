//
//  VariantBBuildingPaywallView.swift
//  Cooked
//
//  Combined "Building your plan" animation + paywall reveal.
//  Shows personalized analysis, then transitions to paywall.
//

import SwiftUI

struct VariantBBuildingPaywallView: View {
    let onboardingState: OnboardingState
    let variant: OnboardingVariant
    let onContinue: () -> Void
    let onSkip: () -> Void

    @State private var phase: Phase = .analyzing
    @State private var analysisProgress: CGFloat = 0
    @State private var analysisStepIndex: Int = 0

    private enum Phase {
        case analyzing
        case reveal
        case paywall
    }

    private var analysisSteps: [String] {
        var steps = ["Analyzing your cooking habits..."]
        if let goal = onboardingState.personalization.cookingGoal {
            steps.append("Optimizing for \(goal.title.lowercased())...")
        }
        if let size = onboardingState.personalization.householdSize {
            steps.append("Adjusting for \(size.title.lowercased())...")
        }
        steps.append("Building your personalized plan...")
        return steps
    }

    var body: some View {
        ZStack {
            switch phase {
            case .analyzing:
                analyzingView
            case .reveal:
                revealView
            case .paywall:
                OnboardingPaywallView(
                    headline: onboardingState.personalizedHeadline,
                    subheadline: onboardingState.personalizedSubheadline,
                    variant: variant,
                    onContinue: onContinue,
                    onSkip: onSkip
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: phase)
        .onAppear { startAnalysis() }
    }

    // MARK: - Analyzing Phase

    private var analyzingView: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: analysisProgress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "fork.knife")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange)
            }

            VStack(spacing: 8) {
                if analysisStepIndex < analysisSteps.count {
                    Text(analysisSteps[analysisStepIndex])
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .id(analysisStepIndex)
                }
            }

            Spacer()
        }
        .padding(24)
    }

    // MARK: - Reveal Phase

    private var revealView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Your plan is ready!")
                .font(.title)
                .fontWeight(.bold)

            // Summary of their answers
            VStack(alignment: .leading, spacing: 12) {
                if let goal = onboardingState.personalization.cookingGoal {
                    summaryRow(icon: goal.icon, text: "Goal: \(goal.title)")
                }
                if let freq = onboardingState.personalization.cookingFrequency {
                    summaryRow(icon: freq.icon, text: "Cooking: \(freq.title)")
                }
                if let size = onboardingState.personalization.householdSize {
                    summaryRow(icon: size.icon, text: "Household: \(size.title)")
                }
                if let source = onboardingState.personalization.recipeSource {
                    summaryRow(icon: source.icon, text: "Recipes from: \(source.title)")
                }
            }
            .padding(20)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)

            Spacer()
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func summaryRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.orange)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }

    // MARK: - Animation

    private func startAnalysis() {
        Task { @MainActor in
            let stepDuration: UInt64 = 800
            let totalSteps = analysisSteps.count

            for i in 0..<totalSteps {
                withAnimation(.easeInOut(duration: 0.3)) {
                    analysisStepIndex = i
                }
                withAnimation(.easeInOut(duration: 0.6)) {
                    analysisProgress = CGFloat(i + 1) / CGFloat(totalSteps)
                }
                try? await Task.sleep(for: .milliseconds(stepDuration))
            }

            // Show reveal
            withAnimation {
                phase = .reveal
            }

            OnboardingAnalytics.track(.ahaMomentViewed, properties: ["variant": variant.rawValue])

            // Transition to paywall
            try? await Task.sleep(for: .milliseconds(2000))
            withAnimation {
                phase = .paywall
            }
        }
    }
}
