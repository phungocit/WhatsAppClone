//
//  Message.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 20/3/2024.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation

struct Message: Identifiable, Hashable, Codable {
    @DocumentID var messageId: String?
    let fromId: String
    let toId: String
    let messageText: String
    let timestamp: Timestamp
    let isImage: Bool?
    let isVideo: Bool?
    let isAudio: Bool?
    var user: User?

    var id: String {
        messageId ?? UUID().uuidString
    }

    var chatPartnerId: String {
        fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }

    var isFromCurrentUser: Bool {
        fromId == Auth.auth().currentUser?.uid
    }

    var timestampString: String {
        timestamp.dateValue().timestampString()
    }

    var timeString: String {
        timestamp.dateValue().timeString()
    }
}

struct MessageGroup: Identifiable, Hashable {
    var id: String {
        UUID().uuidString
    }

    let date: Date
    var messages: [Message]
}
