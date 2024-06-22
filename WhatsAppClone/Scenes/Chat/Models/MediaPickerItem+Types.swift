//
//  MediaPickerItem+Types.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 4/22/24.
//

import SwiftUI

struct VideoPickerTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { exportingFile in
                .init(exportingFile.url)
        } importing: { receivedTransferredFile in
            let originalFile = receivedTransferredFile.file
            let uniqueFileName = "\(UUID().uuidString).mov"
            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFileName)
            try FileManager.default.copyItem(at: originalFile, to: copiedFile)
            return .init(url: copiedFile)
        }
    }
}

struct MediaAttachment: Identifiable {
    let id: String
    let type: MediaAttachmentType

    var thumbnail: UIImage {
        switch type {
        case let .photo(thumbnail):
            return thumbnail
        case let .video(thumbnail, _):
            return thumbnail
        case .audio:
            return UIImage()
        }
    }

    var fileURL: URL? {
        switch type {
        case .photo:
            return nil
        case let .video(_, fileURL):
            return fileURL
        case let .audio(voiceURL, _):
            return voiceURL
        }
    }

    var audioDuration: TimeInterval? {
        switch type {
        case let .audio(_, duration):
            return duration
        default: return nil
        }
    }
}

enum MediaAttachmentType: Equatable {
    case photo(_ thumbnail: UIImage)
    case video(_ thumbnail: UIImage, _ url: URL)
    case audio(_ url: URL, _ duration: TimeInterval)

    static func == (lhs: MediaAttachmentType, rhs: MediaAttachmentType) -> Bool {
        switch (lhs, rhs) {
        case (.photo, .photo), (.video, .video), (.audio, .audio):
            return true
        default:
            return false
        }
    }
}
