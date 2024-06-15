//
//  EmojiTextField.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 23/3/2024.
//

import SwiftUI
import UIKit

class UIEmojiTextField: UITextField {
    var isEmoji = false {
        didSet {
            setEmoji()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setEmoji() {
        reloadInputViews()
    }

    override var textInputContextIdentifier: String? {
        return ""
    }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" && isEmoji {
                keyboardType = .default
                return mode

            } else if !isEmoji {
                return mode
            }
        }
        return nil
    }

    override var intrinsicContentSize: CGSize {
        let size = sizeThatFits(.init(width: bounds.width, height: .greatestFiniteMagnitude))
        return CGSize(width: bounds.width, height: size.height)
    }
}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEmoji: Bool
    var placeholder = ""

    func makeUIView(context: Context) -> UIEmojiTextField {
        let emojiTextField = UIEmojiTextField()
        emojiTextField.placeholder = placeholder
        emojiTextField.text = text
        emojiTextField.delegate = context.coordinator
        emojiTextField.isEmoji = isEmoji
        return emojiTextField
    }

    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        uiView.text = text
        uiView.isEmoji = isEmoji
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField

        init(parent: EmojiTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
