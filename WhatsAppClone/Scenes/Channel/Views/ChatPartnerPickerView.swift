//
//  ChatPartnerPickerView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/19/24.
//

import SwiftUI

struct ChatPartnerPickerView: View {
    var onCreate: (_ newChannel: ChannelItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatPartnerPickerViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack(path: $viewModel.navStack) {
            List {
                ForEach(ChatPartnerPickerOption.allCases) { item in
                    HeaderItemView(item: item) {
                        guard item == ChatPartnerPickerOption.newGroup else { return }
                        viewModel.navStack.append(.groupPartnerPicker)
                    }
                }

                Section {
                    ForEach(viewModel.users) { user in
                        ChatPartnerRowView(user: user)
                            .onTapGesture {
                                viewModel.createDirectChannel(user, completion: onCreate)
                            }
                    }
                } header: {
                    Text("Contacts on WhatsApp")
                        .textCase(nil)
                        .bold()
                }

                if viewModel.isPaginatable {
                    loadMoreUsersView
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search name or number"
            )
            .navigationTitle("New Chat")
            .navigationDestination(for: ChannelCreationRoute.self) { route in
                destinationView(for: route)
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $viewModel.errorState.showError) {
                Alert(
                    title: Text("Uh Oh😕"),
                    message: Text(viewModel.errorState.errorMessage),
                    dismissButton: .default(Text("Ok"))
                )
            }
            .toolbar {
                trailingNavItem
            }
            .onAppear {
                viewModel.deSelectAllChatPartners()
            }
        }
    }

    private var loadMoreUsersView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}

extension ChatPartnerPickerView {
    @ViewBuilder
    private func destinationView(for route: ChannelCreationRoute) -> some View {
        switch route {
        case .groupPartnerPicker:
            GroupPartnerPickerView(viewModel: viewModel)
        case .setUpGroupChat:
            NewGroupSetUpView(viewModel: viewModel, onCreate: onCreate)
        }
    }
}

extension ChatPartnerPickerView {
    @ToolbarContentBuilder
    private var trailingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            cancelButton
        }
    }

    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.footnote)
                .bold()
                .foregroundStyle(.gray)
                .padding(8)
                .background(Color(.systemGray5))
                .clipShape(Circle())
        }
    }
}

extension ChatPartnerPickerView {
    private struct HeaderItemView: View {
        let item: ChatPartnerPickerOption
        let onTapHandler: () -> Void

        var body: some View {
            Button {
                onTapHandler()
            } label: {
                buttonBody
            }
        }

        private var buttonBody: some View {
            HStack {
                Image(systemName: item.imageName)
                    .font(.footnote)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())

                Text(item.title)
            }
        }
    }
}

enum ChatPartnerPickerOption: String, CaseIterable, Identifiable {
    case newGroup = "New Group"
    case newContact = "New Contact"
    case newCommunity = "New Community"

    var id: String {
        rawValue
    }

    var title: String {
        rawValue
    }

    var imageName: String {
        switch self {
        case .newGroup:
            return "person.2.fill"
        case .newContact:
            return "person.fill.badge.plus"
        case .newCommunity:
            return "person.3.fill"
        }
    }
}

#Preview {
    ChatPartnerPickerView { _ in }
}
