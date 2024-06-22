//
//  AuthTextFieldView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/18/24.
//

import SwiftUI

struct AuthTextFieldView: View {
    let type: InputType
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: type.imageName)
                .fontWeight(.semibold)
                .frame(width: 30)

            switch type {
            case .password:
                SecureField(type.placeholder, text: $text)
                    .textInputAutocapitalization(type.autocapitalization)
                    .textContentType(type.textContentType)
            default:
                TextField(type.placeholder, text: $text)
                    .textInputAutocapitalization(type.autocapitalization)
                    .keyboardType(type.keyboardType)
                    .textContentType(type.textContentType)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 32)
    }
}

extension AuthTextFieldView {
    enum InputType {
        case email
        case password
        case custom(_ placeholder: String, _ iconName: String)

        var placeholder: String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .custom(let placeholder, _):
                return placeholder
            }
        }

        var imageName: String {
            switch self {
            case .email:
                return "envelope"
            case .password:
                return "lock"
            case .custom(_, let iconName):
                return iconName
            }
        }

        var keyboardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }

        var textContentType: UITextContentType? {
            switch self {
            case .email:
                return .emailAddress
            case .password:
                return .password
            default:
                return .none
            }
        }

        var autocapitalization: TextInputAutocapitalization? {
            switch self {
            case .email, .password:
                return .never
            default:
                return .none
            }
        }
    }
}

#Preview {
    ZStack {
        Color.teal
        VStack {
            AuthTextFieldView(type: .email, text: .constant(""))
            AuthTextFieldView(type: .password, text: .constant(""))
            AuthTextFieldView(type: .custom("BirthDay", "birthday.cake"), text: .constant(""))
        }
    }
}
