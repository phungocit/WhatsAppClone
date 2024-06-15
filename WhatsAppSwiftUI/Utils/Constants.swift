//
//  Constants.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 21/3/2024.
//

import Firebase
import Foundation

struct FirestoreConstants {
    static let userCollection = Firestore.firestore().collection("users")
    static let messageCollection = Firestore.firestore().collection("messages")
}
