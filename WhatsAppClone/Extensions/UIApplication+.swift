//
//  UIApplication+.swift
//  WhatsAppClone
//
//  Created by Foo Tran on 19/6/24.
//

import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
