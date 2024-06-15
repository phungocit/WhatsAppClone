//
//  RegistrationViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 17/3/2024.
//

import SwiftUI

class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var phoneNumber = ""

    func createUser() async throws {
        try await AuthService.shared.createUser(withEmail: email, password: password, fullName: fullName, phoneNumber: phoneNumber)
    }
}
