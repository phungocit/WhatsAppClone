//
//  MessageItem.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/14/24.
//

import Firebase
import SwiftUI

struct MessageItem: Identifiable {
    typealias userId = String
    typealias emoji = String
    typealias emojiCount = Int

    let id: String
    let isGroupChat: Bool
    let text: String
    let type: MessageType
    let ownerUid: String
    let timeStamp: Date
    var sender: UserItem?
    let thumbnailUrl: String?
    var thumbnailWidth: CGFloat?
    var thumbnailHeight: CGFloat?
    var videoURL: String?
    var audioURL: String?
    var audioDuration: TimeInterval?
    var reactions: [emoji: emojiCount] = [:]
    var userReactions: [userId: emoji] = [:]

    var direction: MessageDirection {
        ownerUid == Auth.auth().currentUser?.uid ? .sent : .received
    }

    static let sentPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: true, text: "Holy Spagetti", type: .text, ownerUid: "1", timeStamp: Date(), thumbnailUrl: nil)
    static let receivedPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: false, text: "Hey Dude whats up ", type: .text, ownerUid: "2", timeStamp: Date(), thumbnailUrl: nil)

    var alignment: Alignment {
        direction == .received ? .leading : .trailing
    }

    var horizontalAlignment: HorizontalAlignment {
        direction == .received ? .leading : .trailing
    }

    var backgroundColor: Color {
        direction == .sent ? .bubbleGreen : .bubbleWhite
    }

    var showGroupPartnerInfo: Bool {
        isGroupChat && direction == .received
    }

    var leadingPadding: CGFloat {
        direction == .received ? 0 : horizontalPadding
    }

    var trailingPadding: CGFloat {
        direction == .received ? horizontalPadding : 0
    }

    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0
        let photoHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(photoHeight / photoWidth * imageWidth)
        return CGSize(width: imageWidth, height: imageHeight)
    }

    var imageWidth: CGFloat {
        (UIWindowScene.current?.screenWidth ?? 0) / 1.5
    }

    var audioDurationString: String {
        audioDuration?.formatElapsedTime ?? "00:00"
    }

    var isSentByMe: Bool {
        ownerUid == Auth.auth().currentUser?.uid ?? ""
    }

    var menuAnchor: UnitPoint {
        direction == .received ? .leading : .trailing
    }

    var reactionAnchor: Alignment {
        direction == .sent ? .bottomTrailing : .bottomLeading
    }

    var hasReactions: Bool {
        !reactions.isEmpty
    }

    var currentUserHasReacted: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return userReactions.contains { $0.key == currentUid }
    }

    var currentUserReaction: String? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        return userReactions[currentUid]
    }

    func containsSameOwner(as message: MessageItem) -> Bool {
        if let userA = message.sender, let userB = sender {
            return userA == userB
        } else {
            return false
        }
    }

    static let stubMessages: [MessageItem] = [
        MessageItem(id: UUID().uuidString, isGroupChat: false, text: "Hi There", type: .text, ownerUid: "3", timeStamp: Date(), thumbnailUrl: nil),
        MessageItem(id: UUID().uuidString, isGroupChat: true, text: "Check out this Photo", type: .photo, ownerUid: "4", timeStamp: Date(), thumbnailUrl: nil),
        MessageItem(id: UUID().uuidString, isGroupChat: false, text: "Play out this Video", type: .video, ownerUid: "5", timeStamp: Date(), thumbnailUrl: nil),
        MessageItem(id: UUID().uuidString, isGroupChat: false, text: "", type: .audio, ownerUid: "6", timeStamp: Date(), thumbnailUrl: nil),
    ]

    private let horizontalPadding: CGFloat = 25
}

extension MessageItem {
    init(id: String, isGroupChat: Bool, dict: [String: Any]) {
        self.id = id
        self.isGroupChat = isGroupChat
        text = dict[.text] as? String ?? ""
        let type = dict[.type] as? String ?? "text"
        self.type = MessageType(type) ?? .text
        ownerUid = dict[.ownerUid] as? String ?? ""
        let timeInterval = dict[.timeStamp] as? TimeInterval ?? 0
        timeStamp = Date(timeIntervalSince1970: timeInterval)
        videoURL = dict[.videoURL] as? String ?? nil
        thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        thumbnailWidth = dict[.thumbnailWidth] as? CGFloat ?? nil
        thumbnailHeight = dict[.thumbnailHeight] as? CGFloat ?? nil
        audioURL = dict[.audioURL] as? String ?? nil
        audioDuration = dict[.audioDuration] as? TimeInterval ?? nil
        reactions = dict[.reactions] as? [emoji: emojiCount] ?? [:]
        userReactions = dict[.userReactions] as? [userId: emoji] ?? [:]
    }
}

extension String {
    static let type = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
    static let videoURL = "videoURL"
    static let audioURL = "audioURL"
    static let audioDuration = "audioDuration"
    static let reactions = "reactions"
    static let userReactions = "userReactions"
}
