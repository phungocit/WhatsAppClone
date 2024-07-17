//
//  NewGroupSetUpView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/20/24.
//

import SwiftUI

struct NewGroupSetUpView: View {
    @ObservedObject var viewModel: ChatPartnerPickerViewModel
    var onCreate: (_ newChannel: ChannelItem) -> Void

    @State private var channelName = ""

    var body: some View {
        List {
            Section {
                channelSetUpHeaderView
            }

            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }

            Section {
                SelectedChatPartnerView(users: viewModel.selectedChatPartners) { user in
                    viewModel.handleItemSelection(user)
                }
            } header: {
                let count = viewModel.selectedChatPartners.count
                let maxCount = ChannelContants.maxGroupParticipants

                Text("Participants: \(count) of \(maxCount)")
                    .bold()
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle("New Group")
        .toolbar {
            trailingNavItem
        }
    }

    private var channelSetUpHeaderView: some View {
        HStack {
            profileImageView

            TextField(
                "",
                text: $channelName,
                prompt: Text("Group Name (optional)"),
                axis: .vertical
            )
        }
    }

    private var profileImageView: some View {
        Button {} label: {
            ZStack {
                Image(systemName: "camera.fill")
                    .imageScale(.large)
            }
            .frame(width: 60, height: 60)
            .background(Color(.systemGray6))
            .clipShape(Circle())
        }
    }

    @ToolbarContentBuilder
    private var trailingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Create") {
                if viewModel.isDirectChannel {
                    guard let chatPartner = viewModel.selectedChatPartners.first else { return }
                    viewModel.createDirectChannel(chatPartner, completion: onCreate)
                } else {
                    viewModel.createGroupChannel(channelName, completion: onCreate)
                }
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        NewGroupSetUpView(viewModel: ChatPartnerPickerViewModel()) { _ in }
    }
}
