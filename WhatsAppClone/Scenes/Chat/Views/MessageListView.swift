//
//  MessageListView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/14/24.
//

import SwiftUI

struct MessageListView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MessageListController
    private var viewModel: ChatRoomViewModel

    init(_ viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
    }

    func makeUIViewController(context: Context) -> MessageListController {
        MessageListController(viewModel)
    }

    func updateUIViewController(_ uiViewController: MessageListController, context: Context) {}
}

#Preview {
    MessageListView(ChatRoomViewModel(.placeholder))
}
