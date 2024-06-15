//
//  VideoUploader.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 2/4/2024.
//

import FirebaseStorage
import Foundation

struct VideoUploader {
    static func uploadVideo(data: Data) async throws -> String? {
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference().child("/message_videos/\(fileName)")
        let metaData = StorageMetadata()
        metaData.contentType = "video/quicktime"
        do {
            _ = try await ref.putDataAsync(data, metadata: metaData)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("failed to upload video")
            return nil
        }
    }
}
