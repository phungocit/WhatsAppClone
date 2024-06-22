//
//  ChannelItem.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/22/24.
//

import Firebase
import Foundation

struct ChannelItem: Identifiable, Hashable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimeStamp: Date
    var membersCount: Int
    var adminUids: [String]
    var membersUids: [String]
    var members: [UserItem]
    let createdBy: String

    var isGroupChat: Bool {
        membersCount > 2
    }

    var coverImageUrl: String? {
        if let thumbnailUrl {
            return thumbnailUrl
        }

        if isGroupChat == false {
            return membersExcludingMe.first?.profileImageUrl
        }

        return nil
    }

    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter { $0.uid != currentUid }
    }

    var title: String {
        if let name {
            return name
        }

        if isGroupChat {
            return groupMemberNames
        } else {
            return membersExcludingMe.first?.username ?? "Unknown"
        }
    }

    var isCreatedByMe: Bool {
        createdBy == Auth.auth().currentUser?.uid ?? ""
    }

    var creatorName: String {
        members.first { $0.uid == createdBy }?.username ?? "Someone"
    }

    var allMembersFetched: Bool {
        members.count == membersCount
    }

    static let placeholder = ChannelItem(id: "1", lastMessage: "Hello world", creationDate: Date(), lastMessageTimeStamp: Date(), membersCount: 2, adminUids: [], membersUids: [], members: [], createdBy: "")

    private var thumbnailUrl: String?

    private var groupMemberNames: String {
        let membersCount = membersCount - 1
        let fullNames = membersExcludingMe.map { $0.username }

        if membersCount == 2 {
            // usernmae1 and username2
            return fullNames.joined(separator: " and ")
        } else if membersCount > 2 {
            // usernmae1, username2 and 10 others
            let remainingCount = membersCount - 2
            return fullNames.prefix(2).joined(separator: ", ") + ", and \(remainingCount) " + "others"
        }

        return "Unknown"
    }
}

extension ChannelItem {
    init(_ dict: [String: Any]) {
        self.id = dict[.id] as? String ?? ""
        self.name = dict[.name] as? String? ?? nil
        self.lastMessage = dict[.lastMessage] as? String ?? ""
        let creationInterval = dict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        let lastMsgTimeStampInterval = dict[.lastMessageTimeStamp] as? Double ?? 0
        self.lastMessageTimeStamp = Date(timeIntervalSince1970: lastMsgTimeStampInterval)
        self.membersCount = dict[.membersCount] as? Int ?? 0
        self.adminUids = dict[.adminUids] as? [String] ?? []
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        self.membersUids = dict[.membersUids] as? [String] ?? []
        self.members = dict[.members] as? [UserItem] ?? []
        self.createdBy = dict[.createdBy] as? String ?? ""
    }
}

extension String {
    static let id = "id"
    static let name = "name"
    static let lastMessage = "lastMessage"
    static let creationDate = "creationDate"
    static let lastMessageTimeStamp = "lastMessageTimeStamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let membersUids = "membersUids"
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
    static let createdBy = "createdBy"
    static let lastMessageType = "lastMessageType"
    static let lastMessageOwnerUid = "lastMessageOwnerUid"
}
