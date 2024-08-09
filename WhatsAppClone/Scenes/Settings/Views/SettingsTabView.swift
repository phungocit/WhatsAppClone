//
//  SettingsTabView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/13/24.
//

import PhotosUI
import SwiftUI

struct SettingsTabView: View {
    @StateObject private var viewModel: SettingTabViewModel
    @State private var searchText = ""

    private let currentUser: UserItem

    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        _viewModel = .init(wrappedValue: .init(currentUser))
    }

    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView(viewModel, currentUser: currentUser)

                Section {
                    SettingsItemView(item: .broadCastLists)
                    SettingsItemView(item: .starredMessages)
                    SettingsItemView(item: .linkedDevices)
                }

                Section {
                    SettingsItemView(item: .account)
                    SettingsItemView(item: .privacy)
                    SettingsItemView(item: .chats)
                    SettingsItemView(item: .notifications)
                    SettingsItemView(item: .storage)
                }

                Section {
                    SettingsItemView(item: .help)
                    SettingsItemView(item: .tellFriend)
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem
                if viewModel.enableSaveButton {
                    trailingNavItem
                }
            }
            .alert(isPresent: $viewModel.isShowProgressHUD, view: viewModel.progressHUDView)
            .alert(isPresent: $viewModel.isShowSuccessHUD, view: viewModel.successHUDView)
            .alert("Update your profile", isPresented: $viewModel.isShowUserInfoEditor) {
                TextField("Username", text: $viewModel.name)
                TextField("Bio", text: $viewModel.bio)
                Button("Update") {
                    viewModel.updateUsernameAndBio()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter your new username or bio")
            }
        }
    }
}

extension SettingsTabView {
    @ToolbarContentBuilder
    private var leadingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Sign Out") {
                Task {
                    try? await AuthManager.shared.logOut()
                }
            }
            .foregroundStyle(.red)
        }
    }

    @ToolbarContentBuilder
    private var trailingNavItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                viewModel.uploadProfilePhoto()
            }
            .bold()
        }
    }
}

private struct SettingsHeaderView: View {
    @ObservedObject private var viewModel: SettingTabViewModel

    private let currentUser: UserItem

    init(_ viewModel: SettingTabViewModel, currentUser: UserItem) {
        self.viewModel = viewModel
        self.currentUser = currentUser
    }

    var body: some View {
        Section {
            HStack {
                profileImageView
                userInfoTextView
                    .onTapGesture {
                        viewModel.isShowUserInfoEditor.toggle()
                    }
            }
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .not(.videos)) {
                SettingsItemView(item: .avatar)
            }
        }
    }

    @ViewBuilder
    private var profileImageView: some View {
        if let profilePhoto = viewModel.profilePhoto {
            Image(uiImage: profilePhoto.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
        } else {
            CircularProfileImageView(currentUser.profileImageUrl, size: .custom(55))
        }
    }

    private var userInfoTextView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(currentUser.username)
                    .font(.title2)

                Spacer()

                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Text(currentUser.bioUnwrapped)
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
}

#Preview {
    SettingsTabView(.placeholder)
}
