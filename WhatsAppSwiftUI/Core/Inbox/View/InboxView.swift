//
//  InboxView.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 7/3/2024.
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()
    @State private var showNewMessageView = false
    @State private var showChat = false
    @State private var selectedUser: User?

    private var user: User? {
        viewModel.currentUser
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(viewModel.latestMessages) { message in
                        ZStack {
                            NavigationLink(value: message) {
                                EmptyView()
                            }
                            .opacity(0)
                            InboxRowView(message: message)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .onChange(of: selectedUser) { newValue in
                    showChat = newValue != nil
                }
                .navigationDestination(for: Message.self) { message in
                    if let user = message.user {
                        ChatView(user: user)
                            .navigationBarBackButtonHidden()
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case let .profile(user):
                        ProfileView(user: user)
                            .navigationBarBackButtonHidden()
                    case let .ChatView(user):
                        ChatView(user: user)
                            .navigationBarBackButtonHidden()
                    }
                }
                .navigationDestination(isPresented: $showChat) {
                    if let user = selectedUser {
                        ChatView(user: user)
                            .navigationBarBackButtonHidden()
                    }
                }
                .fullScreenCover(isPresented: $showNewMessageView) {
                    NewMessageView(selectedUser: $selectedUser)
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.visible, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("WhatsApp")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .navigationBarColor(Color(.darkGray))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 24) {
                            Image(systemName: "camera")
                            Image(systemName: "magnifyingglass")
                            if let user {
                                NavigationLink(value: Route.profile(user)) {
                                    Image(systemName: "ellipsis")
                                }
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    }
                }
                Button {
                    showNewMessageView.toggle()
                    selectedUser = nil
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.darkGray))
                        .frame(width: 50, height: 50)
                        .padding()
                        .overlay {
                            Image(systemName: "plus.bubble.fill")
                                .foregroundStyle(.white)
                        }
                }
            }
        }
    }
}

#Preview {
    InboxView()
}
