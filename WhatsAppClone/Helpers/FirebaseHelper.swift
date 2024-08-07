//
//  FirebaseHelper.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 19/6/24.
//

import FirebaseStorage
import Foundation
import UIKit

typealias UploadCompletion = (Result<URL, Error>) -> Void
typealias ProgressHandler = (Double) -> Void

enum UploadError: Error {
    case failedToUploadImage(_ description: String)
    case failedToUploadFile(_ description: String)
}

extension UploadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .failedToUploadImage(description), let .failedToUploadFile(description):
            return description
        }
    }
}

enum FirebaseHelper {
    static func uploadImage(_ image: UIImage, for type: UploadType, completion: @escaping UploadCompletion, progressHandler: @escaping ProgressHandler) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        let storageRef = type.filePath
        let uploadTask = storageRef.putData(imageData) { _, error in
            if let error {
                print("Failed to upload image to Storage:", error.localizedDescription)
                completion(.failure(UploadError.failedToUploadImage(error.localizedDescription)))
                return
            }

            storageRef.downloadURL(completion: completion)
        }

        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
            progressHandler(percentage)
        }
    }

    // This is going to be responsible for uploading both video and audio file to our storage bucket
    static func uploadFile(for type: UploadType, fileURL: URL, completion: @escaping UploadCompletion, progressHandler: @escaping ProgressHandler) {
        let storageRef = type.filePath
        let uploadTask = storageRef.putFile(from: fileURL) { _, error in
            if let error {
                print("Failed to upload file to Storage:", error.localizedDescription)
                completion(.failure(UploadError.failedToUploadFile(error.localizedDescription)))
                return
            }

            storageRef.downloadURL(completion: completion)
        }

        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
            progressHandler(percentage)
        }
    }
}

extension FirebaseHelper {
    enum UploadType {
        case profilePhoto
        case photoMessage
        case videoMessage
        case audioMessage

        var filePath: StorageReference {
            let filename = UUID().uuidString
            switch self {
            case .profilePhoto:
                return FirebaseConstants.StorageRef.child("profile_photos").child(filename)
            case .photoMessage:
                return FirebaseConstants.StorageRef.child("photo_messages").child(filename)
            case .videoMessage:
                return FirebaseConstants.StorageRef.child("video_messages").child(filename)
            case .audioMessage:
                return FirebaseConstants.StorageRef.child("voice_messages").child(filename)
            }
        }
    }
}
