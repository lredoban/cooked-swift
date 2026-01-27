//
//  VariantAAccountView.swift
//  Cooked
//
//  Post-paywall account creation screen.
//

import SwiftUI

struct VariantAAccountView: View {
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

            Button("Sign in with Apple") {
                // TODO: Apple Sign In integration
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

            Button("Skip for now") {
                onComplete()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private var isFormValid: Bool {
        email.contains("@") && password.count >= 6
    }

    private func createAccount() async {
        isCreating = true
        // TODO: Wire to SupabaseService.signUp
        OnboardingAnalytics.track(.accountCreated, properties: ["method": "email"])
        try? await Task.sleep(for: .milliseconds(500))
        isCreating = false
        onComplete()
    }
}
