//
//  NavigationBarColorModifier.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 15/6/24.
//

import SwiftUI

extension View {
    func navigationBarColor(_ backgroundColor: Color) -> some View {
        modifier(NavigationBarColorModifier(backgroundColor: backgroundColor))
    }
}

struct NavigationBarColorModifier: ViewModifier {
    var backgroundColor: Color

    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(backgroundColor)
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
    }
}
