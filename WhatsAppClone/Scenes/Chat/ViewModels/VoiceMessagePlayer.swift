//
//  VoiceMessagePlayer.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 22/6/24.
//

import AVFoundation
import Foundation

final class VoiceMessagePlayer: ObservableObject {
    @Published var playbackState = PlaybackState.stopped
    @Published var currentTime = CMTime.zero

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var currentURL: URL?
    private var currentTimeObserver: Any?
    private var timeScale = CMTimeScale(NSEC_PER_SEC)

    deinit {
        tearDown()
    }

    func playAudio(from url: URL) {
        if let currentURL, currentURL == url {
            resumePlaying()
        } else {
            currentURL = url
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            playbackState = .playing
            observerCurrentPlayerTime()
            observerEndOfPlayback()
        }
    }

    func pauseAudio() {
        player?.pause()
        playbackState = .paused
    }

    func seek(to timeInterval: TimeInterval) {
        guard let player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: timeScale)
        player.seek(to: targetTime)
    }
}

// MARK: - Private methods
private extension VoiceMessagePlayer {
    func observerCurrentPlayerTime() {
        currentTimeObserver = player?.addPeriodicTimeObserver(
            forInterval: .init(seconds: 0.1, preferredTimescale: timeScale),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = time
        }
    }

    func observerEndOfPlayback() {
        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.stopAudio()
        }
    }

    func resumePlaying() {
        if [.stopped, .paused].contains(playbackState) {
            player?.play()
            playbackState = .playing
        }
    }

    func stopAudio() {
        player?.pause()
        player?.seek(to: .zero)
        playbackState = .stopped
        currentTime = .zero
    }

    func removeObservers() {
        guard let currentTimeObserver else { return }
        player?.removeTimeObserver(currentTimeObserver)
        self.currentTimeObserver = nil
    }

    func tearDown() {
        removeObservers()
        player = nil
        playerItem = nil
        currentURL = nil
    }
}

extension VoiceMessagePlayer {
    enum PlaybackState {
        case stopped, playing, paused
    }
}
