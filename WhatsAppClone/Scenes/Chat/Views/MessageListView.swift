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
    @ObservedObject var voiceMessagePlayer: VoiceMessagePlayer

    init(_ viewModel: ChatRoomViewModel, voiceMessagePlayer: VoiceMessagePlayer) {
        self.viewModel = viewModel
        self.voiceMessagePlayer = voiceMessagePlayer
    }

    func makeUIViewController(context: Context) -> MessageListController {
        MessageListController(viewModel, voiceMessagePlayer: voiceMessagePlayer)
    }

    func updateUIViewController(_ uiViewController: MessageListController, context: Context) {}
}

#Preview {
    MessageListView(ChatRoomViewModel(.placeholder), voiceMessagePlayer: VoiceMessagePlayer())
}
