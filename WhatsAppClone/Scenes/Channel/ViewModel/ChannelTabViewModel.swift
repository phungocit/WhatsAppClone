//
//  ChannelTabViewModel.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/22/24.
//

import Firebase
import Foundation

enum ChannelTabRoutes: Hashable {
    case chatRoom(_ channel: ChannelItem)
}

final class ChannelTabViewModel: ObservableObject {
    @Published var navRoutes = [ChannelTabRoutes]()
    @Published var navigateToChatRoom = false
    @Published var newChannel: ChannelItem?
    @Published var showChatPartnerPickerView = false
    @Published var channels = [ChannelItem]()
    typealias ChannelId = String
    @Published var channelDictionary: [ChannelId: ChannelItem] = [:]

    private let currentUser: UserItem

    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        fetchCurrentUserChannels()
        // dummyData()
    }

    func onNewChannelCreation(_ channel: ChannelItem) {
        showChatPartnerPickerView = false
        newChannel = channel
        navigateToChatRoom = true
    }

    private func fetchCurrentUserChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsRef.child(currentUid).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }

            dict.forEach { key, _ in
                let channelId = key
                self?.getChannel(with: channelId)
            }
        } withCancel: { error in
            print("Failed to get the current user's channelIds: \(error.localizedDescription)")
        }
    }

    private func getChannel(with channelId: String) {
        FirebaseConstants.ChannelsRef.child(channelId).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any], let self = self else { return }

            var channel = ChannelItem(dict)
            self.getChannelMembers(channel) { members in
                channel.members = members
                channel.members.append(self.currentUser)
                self.channelDictionary[channelId] = channel
                self.reloadData()
                print("channel: \(channel)")
            }
        } withCancel: { error in
            print("Failed to get the channel for id \(channelId): \(error.localizedDescription)")
        }
    }

    private func getChannelMembers(_ channel: ChannelItem, completion: @escaping (_ members: [UserItem]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let channelMemberUids = Array(channel.membersUids.filter { $0 != currentUid }.prefix(2))
        UserService.getUsers(with: channelMemberUids) { userNode in
            completion(userNode.users)
        }
    }

    private func reloadData() {
        channels = Array(channelDictionary.values)
        channels.sort { $0.lastMessageTimeStamp > $1.lastMessageTimeStamp }
    }

    private func dummyData() {
        channelDictionary = [
            "0": ChannelItem([
                "membersUids": ["1", "2"],
                "id": "0",
                "lastMessageTimeStamp": 1718848736.521181,
                "createdBy": "1",
                "lastMessage": "Hello",
                "adminUids": ["1"],
                "members": [
                    UserItem(uid: "1", username: "Black Panther", email: "blackpanther@test.com"),
                    UserItem(uid: "2", username: "Spiderman", email: "spiderman@test.com")
                ],
                "membersCount": 2,
                "creationDate": 1718848736.521181,
                "lastMessageOwnerUid": "1",
                "lastMessageType": MessageType.text.title
            ]),
            "1": ChannelItem([
                "membersUids": ["1", "2", "3"],
                "id": "1",
                "lastMessageTimeStamp": 1718848736.521181,
                "createdBy": "1",
                "lastMessage": "Hello eveyone",
                "adminUids": ["2"],
                "members": [
                    UserItem(uid: "1", username: "Black Panther", email: "blackpanther@test.com"),
                    UserItem(uid: "2", username: "Spiderman", email: "spiderman@test.com"),
                    UserItem(uid: "3", username: "Iron Man", email: "ironman@test.com")
                ],
                "membersCount": 3,
                "creationDate": 1718848736.521181,
                "lastMessageOwnerUid": "2",
                "lastMessageType": MessageType.photo.title
            ]),
            "2": ChannelItem([
                "membersUids": ["4", "5"],
                "id": "channel2",
                "lastMessageTimeStamp": 1718858736.521181,
                "createdBy": "4",
                "lastMessage": "Are you coming?",
                "adminUids": ["4"],
                "members": [
                    UserItem(uid: "4", username: "Thor", email: "thor@test.com"),
                    UserItem(uid: "5", username: "Hulk", email: "hulk@test.com")
                ],
                "membersCount": 2,
                "creationDate": 1718858736.521181,
                "lastMessageOwnerUid": "5",
                "lastMessageType": MessageType.text.title
            ]),
            "3": ChannelItem([
                "membersUids": ["6", "7", "8"],
                "id": "channel3",
                "lastMessageTimeStamp": 1718868736.521181,
                "createdBy": "6",
                "lastMessage": "Meeting at 5 PM.",
                "adminUids": ["6"],
                "members": [
                    UserItem(uid: "6", username: "Captain America", email: "captain@test.com"),
                    UserItem(uid: "7", username: "Black Widow", email: "blackwidow@test.com"),
                    UserItem(uid: "8", username: "Hawkeye", email: "hawkeye@test.com")
                ],
                "membersCount": 3,
                "creationDate": 1718868736.521181,
                "lastMessageOwnerUid": "7",
                "lastMessageType": MessageType.text.title
            ]),
            "4": ChannelItem([
                "membersUids": ["9", "10"],
                "id": "channel4",
                "lastMessageTimeStamp": 1718878736.521181,
                "createdBy": "9",
                "lastMessage": "Got it.",
                "adminUids": ["9"],
                "members": [
                    UserItem(uid: "9", username: "Doctor Strange", email: "strange@test.com"),
                    UserItem(uid: "10", username: "Scarlet Witch", email: "scarlet@test.com")
                ],
                "membersCount": 2,
                "creationDate": 1718878736.521181,
                "lastMessageOwnerUid": "10",
                "lastMessageType": MessageType.text.title
            ]),
            "5": ChannelItem([
                "membersUids": ["11", "12", "13"],
                "id": "channel5",
                "lastMessageTimeStamp": 1718888736.521181,
                "createdBy": "11",
                "lastMessage": "Let's go!",
                "adminUids": ["11"],
                "members": [
                    UserItem(uid: "11", username: "Ant-Man", email: "antman@test.com"),
                    UserItem(uid: "12", username: "Wasp", email: "wasp@test.com"),
                    UserItem(uid: "13", username: "Falcon", email: "falcon@test.com")
                ],
                "membersCount": 3,
                "creationDate": 1718888736.521181,
                "lastMessageOwnerUid": "11",
                "lastMessageType": MessageType.text.title
            ]),
            "6": ChannelItem([
                "membersUids": ["14", "15"],
                "id": "channel6",
                "lastMessageTimeStamp": 1718898736.521181,
                "createdBy": "14",
                "lastMessage": "Can we talk?",
                "adminUids": ["14"],
                "members": [
                    UserItem(uid: "14", username: "Vision", email: "vision@test.com"),
                    UserItem(uid: "15", username: "War Machine", email: "warmachine@test.com")
                ],
                "membersCount": 2,
                "creationDate": 1718898736.521181,
                "lastMessageOwnerUid": "15",
                "lastMessageType": MessageType.text.title
            ]),
            "7": ChannelItem([
                "membersUids": ["16", "17", "18"],
                "id": "channel7",
                "lastMessageTimeStamp": 1718908736.521181,
                "createdBy": "16",
                "lastMessage": "On my way.",
                "adminUids": ["16"],
                "members": [
                    UserItem(uid: "16", username: "Winter Soldier", email: "winter@test.com"),
                    UserItem(uid: "17", username: "Nick Fury", email: "nickfury@test.com"),
                    UserItem(uid: "18", username: "Maria Hill", email: "mariahill@test.com")
                ],
                "membersCount": 3,
                "creationDate": 1718908736.521181,
                "lastMessageOwnerUid": "18",
                "lastMessageType": MessageType.text.title
            ]),
            "8": ChannelItem([
                "membersUids": ["19", "20"],
                "id": "channel8",
                "lastMessageTimeStamp": 1718918736.521181,
                "createdBy": "19",
                "lastMessage": "Thanks!",
                "adminUids": ["19"],
                "members": [
                    UserItem(uid: "19", username: "Star-Lord", email: "starlord@test.com"),
                    UserItem(uid: "20", username: "Gamora", email: "gamora@test.com")
                ],
                "membersCount": 2,
                "creationDate": 1718918736.521181,
                "lastMessageOwnerUid": "20",
                "lastMessageType": MessageType.text.title
            ]),
            "9": ChannelItem([
                "membersUids": ["21", "22", "23"],
                "id": "channel9",
                "lastMessageTimeStamp": 1718928736.521181,
                "createdBy": "21",
                "lastMessage": "Okay.",
                "adminUids": ["21"],
                "members": [
                    UserItem(uid: "21", username: "Rocket Raccoon", email: "rocket@test.com"),
                    UserItem(uid: "22", username: "Groot", email: "groot@test.com"),
                    UserItem(uid: "23", username: "Drax", email: "drax@test.com")
                ],
                "membersCount": 3,
                "creationDate": 1718928736.521181,
                "lastMessageOwnerUid": "23",
                "lastMessageType": MessageType.text.title
            ]),
            "10": ChannelItem([
                "membersUids": ["24", "25"],
                "id": "channel10",
                "lastMessageTimeStamp": 1718938736.521181,
                "createdBy": "24",
                "lastMessage": "What's up?",
                "adminUids": ["24"],
                "members": [
                    UserItem(uid: "24", username: "Nebula", email: "nebula@test.com"),
                    UserItem(uid: "25", username: "Mantis", email: "mantis@test.com")
                ],
                "membersCount": 2,
                "creationDate": 1718938736.521181,
                "lastMessageOwnerUid": "24",
                "lastMessageType": MessageType.text.title
            ])
        ]
        reloadData()
    }
}
