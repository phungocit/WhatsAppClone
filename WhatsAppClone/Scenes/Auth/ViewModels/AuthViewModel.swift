//
//  AuthViewModel.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/18/24.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Uh Oh")

    // MARK: Computed Properties
    var disableLoginButton: Bool {
        email.isEmpty || password.isEmpty || isLoading
    }

    var disableSignUpButton: Bool {
        email.isEmpty || password.isEmpty || username.isEmpty || isLoading
    }

    func handleSignUp() async {
        isLoading = true
        do {
            try await AuthManager.shared.createAccount(for: username, with: email, and: password)
        } catch {
            errorState.errorMessage = "Failed to create an account \(error.localizedDescription)"
            errorState.showError = true
            isLoading = false
        }
    }

    func handleLogin() async {
        isLoading = true
        do {
            try await AuthManager.shared.login(with: email, and: password)
        } catch {
            errorState.errorMessage = "Failed to login \(error.localizedDescription)"
            errorState.showError = true
            isLoading = false
        }
    }
}
