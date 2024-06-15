//
//  AuthService.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 17/3/2024.
//

import Firebase
import FirebaseFirestoreSwift
import Foundation

class AuthService {
    @Published var userSession: FirebaseAuth.User?

    static let shared = AuthService()

    init() {
        userSession = Auth.auth().currentUser
        loadCurrentUserData()
    }

    @MainActor
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            userSession = result.user
            loadCurrentUserData()
        } catch {
            print("failed to login with error \(error.localizedDescription)")
        }
    }

    @MainActor
    func createUser(withEmail email: String, password: String, fullName: String, phoneNumber: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            userSession = result.user
            try await uploadUserData(email: email, fullname: fullName, phoneNumber: phoneNumber, id: result.user.uid)
            loadCurrentUserData()
        } catch {
            print("failed to create user with error \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            userSession = nil
            UserService.shared.currentUser = nil
        } catch {
            print("failed to sign out with error \(error.localizedDescription)")
        }
    }
}

private extension AuthService {
    func uploadUserData(email: String, fullname: String, phoneNumber: String, id: String) async throws {
        let user = User(fullName: fullname, email: email, phoneNumber: phoneNumber)
        guard let encodedUser = try? Firestore.Encoder().encode(user) else { return }
        try await Firestore.firestore().collection("users").document(id).setData(encodedUser)
    }

    func loadCurrentUserData() {
        Task { try await UserService.shared.fetchCurrentUser() }
    }
}
