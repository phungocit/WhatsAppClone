//
//  SettingsTabView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/13/24.
//

import SwiftUI

struct SettingsTabView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView()

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
}

private struct SettingsHeaderView: View {
    var body: some View {
        Section {
            HStack {
                Circle()
                    .frame(width: 55, height: 55)
                userInfoTextView
            }
            SettingsItemView(item: .avatar)
        }
    }

    private var userInfoTextView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Qa User 13")
                    .font(.title2)

                Spacer()

                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.blue)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }

            Text("Hey there! I am using WhatsApp")
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
}

#Preview {
    SettingsTabView()
}
