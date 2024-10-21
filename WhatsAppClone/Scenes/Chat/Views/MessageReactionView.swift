//
//  MessageReactionView.swift
//  WhatsAppClone
//
//  Created by Tran Ngoc Phu on 20/10/24.
//

import SwiftUI

struct MessageReactionView: View {
    let message: MessageItem

    private var emojis: [String] {
        message.reactions.map { $0.key }
    }

    private var emojisCount: Int {
        let stats = message.reactions.map { $0.value }
        return stats.reduce(0, +)
    }

    var body: some View {
        if message.hasReactions {
            HStack(spacing: 2) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .fontWeight(.semibold)
                }
                if emojisCount > 1 {
                    Text(emojisCount.description)
                        .fontWeight(.semibold)
                }
            }
            .font(.footnote)
            .padding(4)
            .padding(.horizontal, 2)
            .background(Capsule().fill(.thinMaterial))
            .overlay(
                Capsule()
                    .stroke(message.backgroundColor, lineWidth: 2)
            )
            .shadow(color: message.backgroundColor.opacity(0.3), radius: 5, x: 0, y: 5)
        }
    }
}

#Preview {
    MessageReactionView(message: .sentPlaceholder)
}
