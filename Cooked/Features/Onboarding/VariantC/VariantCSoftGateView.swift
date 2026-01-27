//
//  VariantCSoftGateView.swift
//  Cooked
//
//  Soft gate + account creation. Second conversion opportunity for users who skipped the first paywall.
//

import SwiftUI

struct VariantCSoftGateView: View {
    @Environment(SubscriptionState.self) private var subscriptionState
    let showTrialOption: Bool
    let onComplete: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var isCreating = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 56))
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)

                Text("Create your account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

                Text("Save your recipes and menus across devices.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .padding(14)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)

            // Primary: trial if they skipped paywall, otherwise just create account
            if showTrialOption && !subscriptionState.isPro {
                Button {
                    Task { await createAccount() }
                } label: {
                    HStack {
                        if isCreating {
                            ProgressView().tint(.white)
                        } else {
                            Text("Start free trial")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isFormValid ? Color.orange : Color(.systemGray4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!isFormValid || isCreating)
                .padding(.horizontal, 24)

                Button("Continue with free") {
                    OnboardingAnalytics.track(.accountCreated, properties: ["method": "email", "tier": "free"])
                    onComplete()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            } else {
                Button {
                    Task { await createAccount() }
                } label: {
                    HStack {
                        if isCreating {
                            ProgressView().tint(.white)
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isFormValid ? Color.orange : Color(.systemGray4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!isFormValid || isCreating)
                .padding(.horizontal, 24)

                Button("Skip for now") {
                    onComplete()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Button("Sign in with Apple") {
                OnboardingAnalytics.track(.accountCreated, properties: ["method": "apple"])
                onComplete()
            }
            .font(.body)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var isFormValid: Bool {
        email.contains("@") && password.count >= 6
    }

    private func createAccount() async {
        isCreating = true
        OnboardingAnalytics.track(.accountCreated, properties: ["method": "email"])
        try? await Task.sleep(for: .milliseconds(500))
        isCreating = false
        onComplete()
    }
}
