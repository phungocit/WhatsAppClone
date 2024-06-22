//
//  CustomModifiers.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/14/24.
//

import SwiftUI

private struct BubbleTailModifier: ViewModifier {
    var direction: MessageDirection

    func body(content: Content) -> some View {
        content.overlay(alignment: direction == .received ? .bottomLeading : .bottomTrailing) {
            BubbleTailView(direction: direction)
        }
    }
}

extension View {
    func applyTail(_ direction: MessageDirection) -> some View {
        modifier(BubbleTailModifier(direction: direction))
    }
}
