//
//  MediaPlayerView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 4/23/24.
//

import AVKit
import SwiftUI

struct MediaPlayerView: View {
    let player: AVPlayer
    let dismissPlayer: () -> Void

    var body: some View {
        VideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                cancelButton
                    .padding()
            }
            .onAppear {
                player.play()
            }
    }

    var cancelButton: some View {
        Button {
            dismissPlayer()
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
}
