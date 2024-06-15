//
//  ContentView.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 2/3/2024.
//

import SwiftUI

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        if viewModel.userSession != nil {
            MainTabBarView()
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    RootView()
}
