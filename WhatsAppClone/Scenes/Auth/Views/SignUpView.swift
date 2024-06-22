//
//  SignUpView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/18/24.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            Spacer()
            AuthHeaderView()
            AuthTextFieldView(type: .email, text: $authViewModel.email)

            let usernameType = AuthTextFieldView.InputType.custom("Username", "at")

            AuthTextFieldView(type: usernameType, text: $authViewModel.username)

            AuthTextFieldView(type: .password, text: $authViewModel.password)

            AuthButtonView(title: "Create an Account") {
                Task {
                    await authViewModel.handleSignUp()
                }
            }
            .disabled(authViewModel.disableSignUpButton)

            Spacer()

            backButton
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            LinearGradient(colors: [.green, .green.opacity(0.8), .teal], startPoint: .top, endPoint: .bottom)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }

    var backButton: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "sparkles")

                Text("Already created an account ? ")
                +
                Text("Log in").bold()

                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    SignUpView(authViewModel: AuthViewModel())
}
