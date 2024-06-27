//
//  RootViewModel.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/18/24.
//

import Combine
import Foundation

final class RootViewModel: ObservableObject {
    @Published private(set) var authState = AuthState.pending

    private var cancallable: AnyCancellable?

    init() {
        cancallable = AuthManager.shared.authState.receive(on: DispatchQueue.main)
            .sink { [weak self] latestAuthState in
                self?.authState = latestAuthState
            }
    }
}
