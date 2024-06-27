//
//  LaunchView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 20/06/2024.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(.whatsapp)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LaunchView()
}
