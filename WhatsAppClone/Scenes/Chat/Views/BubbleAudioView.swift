//
//  BubbleAudioView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/15/24.
//

import AVFoundation
import SwiftUI

struct BubbleAudioView: View {
    private let item: MessageItem

    @EnvironmentObject private var voiceMessagePlayer: VoiceMessagePlayer
    @State private var sliderValue = 0.0
    @State private var playbackState = VoiceMessagePlayer.PlaybackState.stopped
    @State private var playbackTime = "00:00"
    @State private var sliderRange: ClosedRange<Double>
    @State private var isDraggingSlider = false

    init(item: MessageItem) {
        self.item = item
        let audioDuration = item.audioDuration ?? 20
        _sliderRange = State(wrappedValue: 0 ... audioDuration)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
                    .offset(y: 5)
            }

            if item.direction == .sent {
                timeStampTextView
            }

            HStack {
                playButton
                Slider(value: $sliderValue, in: sliderRange, onEditingChanged: sliderEditingChanged)
                    .tint(.gray)

                Text(playbackState == .stopped ? item.audioDurationString : playbackTime)
                    .foregroundStyle(.gray)
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(5)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .applyTail(item.direction)
            .contextMenu {
                Button {} label: {
                    Label("ContextMenu", systemImage: "heart")
                }
            }

            if item.direction == .received {
                timeStampTextView
            }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
        .onReceive(voiceMessagePlayer.$playbackState) { state in
            observePlaybackState(state)
        }
        .onReceive(voiceMessagePlayer.$currentTime) { currentTime in
            guard voiceMessagePlayer.currentURL?.absoluteString == item.audioURL else { return }
            listen(to: currentTime)
        }
    }
}

private extension BubbleAudioView {
    var playButton: some View {
        Button {
            handlePlayVoiceMessage()
        } label: {
            Image(systemName: playbackState.icon)
                .resizable()
                .frame(width: 12, height: 12)
                .padding(10)
                .background(item.direction == .received ? .green : .white)
                .clipShape(Circle())
                .foregroundStyle(item.direction == .received ? .white : .black)
        }
    }

    var timeStampTextView: some View {
        Text(item.timeStamp.formatToTime)
            .font(.footnote)
            .foregroundStyle(.gray)
    }

    var isCorrectVoiceMessage: Bool {
        voiceMessagePlayer.currentURL?.absoluteString == item.audioURL
    }

    func sliderEditingChanged(editing: Bool) {
        isDraggingSlider = editing
        if !editing, isCorrectVoiceMessage {
            voiceMessagePlayer.seek(to: sliderValue)
        }
    }

    func handlePlayVoiceMessage() {
        if playbackState == .stopped || playbackState == .paused {
            guard let audioURLString = item.audioURL, let url = URL(string: audioURLString) else { return }
            voiceMessagePlayer.playAudio(from: url)
        } else {
            voiceMessagePlayer.pauseAudio()
        }
    }

    func observePlaybackState(_ state: VoiceMessagePlayer.PlaybackState) {
        switch state {
        case .stopped:
            playbackState = .stopped
            sliderValue = 0
        case .playing, .paused:
            if isCorrectVoiceMessage {
                playbackState = state
            }
        }
    }

    func listen(to currentTime: CMTime) {
        guard !isDraggingSlider else { return }
        playbackTime = currentTime.seconds.formatElapsedTime
        sliderValue = currentTime.seconds
    }
}

#Preview {
    ScrollView {
        BubbleAudioView(item: .receivedPlaceholder)
        BubbleAudioView(item: .sentPlaceholder)
    }
    .environmentObject(VoiceMessagePlayer())
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
