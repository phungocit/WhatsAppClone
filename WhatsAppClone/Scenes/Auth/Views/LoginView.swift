//
//  LoginView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/18/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                AuthHeaderView()

                AuthTextFieldView(type: .email, text: $authViewModel.email)
                AuthTextFieldView(type: .password, text: $authViewModel.password)

                forgotPasswordButton

                AuthButtonView(title: "Log in now") {
                    Task {
                        await authViewModel.handleLogin()
                    }
                }
                .disabled(authViewModel.disableLoginButton)

                Spacer()

                signUpButton
                    .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.teal.gradient)
            .ignoresSafeArea()
            .alert(isPresented: $authViewModel.errorState.showError) {
                Alert(
                    title: Text(authViewModel.errorState.errorMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
    }

    var forgotPasswordButton: some View {
        Button {} label: {
            Text("Forgot Password ?")
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 32)
                .bold()
                .padding(.vertical)
        }
    }

    var signUpButton: some View {
        NavigationLink {
            SignUpView(authViewModel: authViewModel)
        } label: {
            HStack {
                Image(systemName: "sparkles")

                Text("Don't have an account ? ")
                +
                Text("Create one").bold()

                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    LoginView()
}
