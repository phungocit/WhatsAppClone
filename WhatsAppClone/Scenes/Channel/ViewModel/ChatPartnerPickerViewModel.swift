//
//  ChatPartnerPickerViewModel.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/19/24.
//

import Combine
import Firebase
import Foundation

enum ChannelCreationRoute {
    case groupPartnerPicker
    case setUpGroupChat
}

enum ChannelContants {
    static let maxGroupParticipants = 12
}

enum ChannelCreationError: Error {
    case noChatPartner
    case failedToCreateUniqueIds
}

@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Uh Oh")

    @Published private(set) var users = [UserItem]()

    var showSelectedUsers: Bool {
        !selectedChatPartners.isEmpty
    }

    var disableNextButton: Bool {
        selectedChatPartners.isEmpty
    }

    var isPaginatable: Bool {
        !users.isEmpty
    }

    private var subscription: AnyCancellable?
    private var lastCursor: String?
    private var currentUser: UserItem?

    private var isDirectChannel: Bool {
        selectedChatPartners.count == 1
    }

    init() {
        listenForAuthState()
    }

    deinit {
        subscription?.cancel()
        subscription = nil
    }

    // MARK: - Public Methods
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUid }
            users.append(contentsOf: fetchedUsers)
            lastCursor = userNode.currentCursor
            print("lastCursor: \(lastCursor ?? "") \(users.count)")
        } catch {
            print("💿 Failed to fetch users in ChatPartnerPickerViewModel")
        }
    }

    func deSelectAllChatPartners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedChatPartners.removeAll()
        }
    }

    func handleItemSelection(_ item: UserItem) {
        if isUserSelected(item) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            guard selectedChatPartners.count < ChannelContants.maxGroupParticipants else {
                let errorMessage = "Sorry, We only allow a Maximum of \(ChannelContants.maxGroupParticipants) participants in a group chat."
                showError(errorMessage)
                return
            }

            selectedChatPartners.append(item)
        }
    }

    func isUserSelected(_ user: UserItem) -> Bool {
        selectedChatPartners.contains { $0.uid == user.uid }
    }

    func createDirectChannel(_ chatPartner: UserItem, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        selectedChatPartners.append(chatPartner)

        Task {
            // if existing DM, get the channel
            if let channelId = await verifyIfDirectChannelExits(with: chatPartner.uid) {
                let snapshot = try await FirebaseConstants.ChannelsRef.child(channelId).getData()
                let channelDict = snapshot.value as! [String: Any]
                var directChannel = ChannelItem(channelDict)
                // MARK: Add current User to channel member
                directChannel.members = selectedChatPartners
                if let currentUser {
                    directChannel.members.append(currentUser)
                }
                completion(directChannel)
            } else {
                // create a new DM with the user
                let channelCreation = createChannel(nil)
                switch channelCreation {
                case .success(let channel):
                    completion(channel)
                case .failure(let failure):
                    showError("Sorry! Something Went Wrong While We Were Trying to Setup Your Chat")
                    print("Failed to create a Direct Channel: \(failure.localizedDescription)")
                }
            }
        }
    }

    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        let channelCreation = createChannel(groupName)
        switch channelCreation {
        case .success(let channel):
            completion(channel)
        case .failure(let failure):
            showError("Sorry! Something Went Wrong While We Were Trying to Setup Your Group Chat")
            print("Failed to create a Group Channel: \(failure.localizedDescription)")
        }
    }
}

// MARK: - Private methods
private extension ChatPartnerPickerViewModel {
    typealias ChannelId = String
    private func verifyIfDirectChannelExits(with chatPartnerId: String) async -> ChannelId? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartnerId).getData(),
              snapshot.exists()
        else { return nil }

        let directMessageDict = snapshot.value as! [String: Bool]
        let channelId = directMessageDict.compactMap { $0.key }.first
        return channelId
    }

    private func listenForAuthState() {
        subscription = AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            switch authState {
            case .loggedIn(let loggedInUser):
                self?.currentUser = loggedInUser
                Task { await self?.fetchUsers() }
            default:
                break
            }
        }
    }

    private func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }

    private func createChannel(_ channelName: String?) -> Result<ChannelItem, Error> {
        guard !selectedChatPartners.isEmpty else { return .failure(ChannelCreationError.noChatPartner) }

        guard
            let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
            let currentUid = Auth.auth().currentUser?.uid,
            let messageId = FirebaseConstants.MessagesRef.childByAutoId().key
        else { return .failure(ChannelCreationError.failedToCreateUniqueIds) }

        let timeStamp = Date().timeIntervalSince1970
        var membersUids = selectedChatPartners.compactMap { $0.uid }
        membersUids.append(currentUid)

        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue

        var channelDict: [String: Any] = [
            .id: channelId,
            .lastMessage: newChannelBroadcast,
            .lastMessageType: newChannelBroadcast,
            .creationDate: timeStamp,
            .lastMessageTimeStamp: timeStamp,
            .membersUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid],
            .createdBy: currentUid
        ]

        if let channelName = channelName, !channelName.isEmptyOrWhiteSpace {
            channelDict[.name] = channelName
        }

        let messageDict: [String: Any] = [.type: newChannelBroadcast, .timeStamp: timeStamp, .ownerUid: currentUid]

        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        FirebaseConstants.MessagesRef.child(channelId).child(messageId).setValue(messageDict)

        membersUids.forEach { userId in
            /// keeping an index of the channel that a specific user belongs to
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
        }

        /// Makes sure that a direct channel is unique
        if isDirectChannel {
            let chatPartner = selectedChatPartners[0]
            FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartner.uid).setValue([channelId: true])
            FirebaseConstants.UserDirectChannels.child(chatPartner.uid).child(currentUid).setValue([channelId: true])
        }

        var newChannelItem = ChannelItem(channelDict)
        // MARK: Add current User to channel member
        newChannelItem.members = selectedChatPartners
        if let currentUser {
            newChannelItem.members.append(currentUser)
        }
        return .success(newChannelItem)
    }
}
