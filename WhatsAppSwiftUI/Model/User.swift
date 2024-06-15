//
//  User.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 16/3/2024.
//

import FirebaseFirestoreSwift
import Foundation

struct User: Codable, Identifiable, Hashable {
    @DocumentID var uid: String?
    let fullName: String
    let email: String
    let phoneNumber: String
    var profileImageUrl: String?

    var id: String {
        uid ?? UUID().uuidString
    }

    var firstName: String {
        let formatter = PersonNameComponentsFormatter()
        let components = formatter.personNameComponents(from: fullName)
        return components?.givenName ?? fullName
    }
}

extension User {
    static let MOCK_USER = User(fullName: "Elizabeth Olsen", email: "elizabeth.olsen@gmail.com", phoneNumber: "+1111111", profileImageUrl: "elizabeth")
}
