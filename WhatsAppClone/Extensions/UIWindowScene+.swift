//
//  UIWindowScene+.swift
//  WhatsAppClone
//
//  Created by Foo Tran on 19/6/24.
//

import UIKit

extension UIWindowScene {
    static var current: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first { $0 is UIWindowScene } as? UIWindowScene
    }

    var screenHeight: CGFloat {
        UIWindowScene.current?.screen.bounds.height ?? 0
    }

    var screenWidth: CGFloat {
        UIWindowScene.current?.screen.bounds.width ?? 0
    }
}
