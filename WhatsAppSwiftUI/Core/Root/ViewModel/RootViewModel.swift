//
//  RootViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 18/3/2024.
//

import Combine
import Firebase
import Foundation

class RootViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?

    private var cancellable = Set<AnyCancellable>()

    init() {
        setupSubscribers()
    }

    private func setupSubscribers() {
        AuthService.shared.$userSession.sink { [weak self] userSession in
            self?.userSession = userSession
        }
        .store(in: &cancellable)
    }
}
