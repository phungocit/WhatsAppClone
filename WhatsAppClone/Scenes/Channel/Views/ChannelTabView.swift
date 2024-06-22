//
//  ChannelTabView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/13/24.
//

import SwiftUI

struct ChannelTabView: View {
    @StateObject private var viewModel: ChannelTabViewModel
    @State private var searchText = ""

    init(_ currentUser: UserItem) {
        _viewModel = StateObject(wrappedValue: ChannelTabViewModel(currentUser))
    }

    var body: some View {
        NavigationStack(path: $viewModel.navRoutes) {
            List {
                archivedButton

                ForEach(viewModel.channels) { channel in
                    Button {
                        viewModel.navRoutes.append(.chatRoom(channel))
                    } label: {
                        ChannelItemView(channel: channel)
                    }
                }

                inboxFooterView
                    .listRowSeparator(.hidden)
            }
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .listStyle(.plain)
            .toolbar {
                leadingNavItems
                trailingNavItems
            }
            .navigationDestination(for: ChannelTabRoutes.self) { route in
                destinationView(for: route)
            }
            .sheet(isPresented: $viewModel.showChatPartnerPickerView) {
                ChatPartnerPickerView(onCreate: viewModel.onNewChannelCreation)
            }
            .navigationDestination(isPresented: $viewModel.navigateToChatRoom) {
                if let newChannel = viewModel.newChannel {
                    ChatRoomView(channel: newChannel)
                }
            }
        }
    }
}

extension ChannelTabView {
    @ViewBuilder
    private func destinationView(for route: ChannelTabRoutes) -> some View {
        switch route {
        case .chatRoom(let channel):
            ChatRoomView(channel: channel)
        }
    }

    @ToolbarContentBuilder
    private var leadingNavItems: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button {} label: {
                    Label("Select Chats", systemImage: "checkmark.circle")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    @ToolbarContentBuilder
    private var trailingNavItems: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            aiButton
            cameraButton
            newChatButton
        }
    }

    private var aiButton: some View {
        Button {} label: {
            Image(.circle)
        }
    }

    private var newChatButton: some View {
        Button {
            viewModel.showChatPartnerPickerView = true
        } label: {
            Image(.plus)
        }
    }

    private var cameraButton: some View {
        Button {} label: {
            Image(systemName: "camera")
        }
    }

    private var archivedButton: some View {
        Button {} label: {
            Label("Archived", systemImage: "archivebox.fill")
                .bold()
                .padding()
                .foregroundStyle(.gray)
        }
    }

    private var inboxFooterView: some View {
        HStack {
            Image(systemName: "lock.fill")

            Text("Your personal messages are ")
            +
            Text("end-to-end encrypted")
                .foregroundColor(.blue)
        }
        .foregroundStyle(.gray)
        .font(.caption)
        .padding(.horizontal)
    }
}

#Preview {
    ChannelTabView(.placeholder)
}
