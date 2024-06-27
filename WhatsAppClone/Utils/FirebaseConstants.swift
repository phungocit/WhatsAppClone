//
//  FirebaseConstants.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/18/24.
//

import Firebase
import FirebaseStorage
import Foundation

enum FirebaseConstants {
    static let StorageRef = Storage.storage().reference()
    static let UserRef = DatabaseRef.child("users")
    static let ChannelsRef = DatabaseRef.child("channels")
    static let MessagesRef = DatabaseRef.child("channel-messages")
    static let UserChannelsRef = DatabaseRef.child("user-channels")
    static let UserDirectChannels = DatabaseRef.child("user-direct-channels")

    private static let DatabaseRef = Database.database().reference()
}
