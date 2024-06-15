//
//  WelcomeScreen.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 26/3/2024.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showLoginView = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "ellipsis")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.darkGray))
            }
            .padding()
            Image("welcome_image")
                .resizable()
                .frame(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 60)
                .scaledToFill()
            VStack(spacing: 20) {
                Text("Welcome to WhatsApp")
                    .font(.title2)
                    .fontWeight(.semibold)
//                Text("Read our ")
//                    .foregroundStyle(Color.gray) +
//                    Text("Privacy Policy")
//                    .foregroundStyle(Color.blue) +
//                    Text(". Tap Agree and continue to accept the ")
//                    .foregroundStyle(Color.gray) +
//                    Text("Terms of Service")
//                    .foregroundStyle(Color.blue)
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(width: 160, height: 40)
                    .overlay {
                        HStack {
                            Image(systemName: "network")
                            Spacer()
                            Text("English")
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .foregroundStyle(Color(.darkGray))
                        .padding(.horizontal)
                    }
            }
            .font(.subheadline)
            .padding(.top, 24)
            .padding(.horizontal)
            Spacer()
            Button {
                showLoginView.toggle()
            } label: {
                Text("Agree and continue")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(height: 44)
                    .padding(.horizontal)
                    .background(Color(.darkGray))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
    }
}

#Preview {
    WelcomeView()
}
