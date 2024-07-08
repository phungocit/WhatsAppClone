//
//  MessageItems+Types.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/27/24.
//

import Foundation

enum AdminMessageType: String {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChanged
}

enum MessageType: Hashable {
    case admin(_ type: AdminMessageType), text, photo, video, audio

    var title: String {
        switch self {
        case .admin:
            return "admin"
        case .text:
            return "text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "audio"
        }
    }

    var icon: String? {
        switch self {
        case .admin:
            return "megaphone.fill"
        case .text:
            return nil
        case .photo:
            return "photo.fill"
        case .video:
            return "video.fill"
        case .audio:
            return "mic.fill"
        }
    }

    init?(_ stringValue: String) {
        switch stringValue {
        case "text":
            self = .text
        case "photo":
            self = .photo
        case "video":
            self = .video
        case "audio":
            self = .audio
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValue) {
                self = .admin(adminMessageType)
            } else {
                return nil
            }
        }
    }
}

extension MessageType: Equatable {
    static func == (lhs: MessageType, rhs: MessageType) -> Bool {
        switch (lhs, rhs) {
        case let (.admin(leftAdmin), .admin(rightAdmin)):
            return leftAdmin == rightAdmin
        case (.text, .text),
             (.photo, .photo),
             (.video, .video),
             (.audio, .audio):
            return true
        default:
            return false
        }
    }
}

enum MessageDirection {
    case sent, received

    static var random: MessageDirection {
        [MessageDirection.sent, .received].randomElement() ?? .sent
    }
}
