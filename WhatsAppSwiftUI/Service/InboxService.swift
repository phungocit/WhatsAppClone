//
//  InboxService.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 21/3/2024.
//

import Firebase
import Foundation

class InboxService {
    @Published var documentChanges = [DocumentChange]()

    func observeLatestMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = FirestoreConstants.messageCollection.document(uid).collection("latest-messages").order(by: "timestamp", descending: true)
        query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges.filter({
                $0.type == .added || $0.type == .modified
            }) else { return }
            self.documentChanges = changes
        }
    }
}
