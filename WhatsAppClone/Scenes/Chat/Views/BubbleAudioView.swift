//
//  BubbleAudioView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/15/24.
//

import AVFoundation
import SwiftUI

struct BubbleAudioView: View {
    let item: MessageItem

    @StateObject private var voiceMessagePlayer = VoiceMessagePlayer()
    @State private var sliderValue = 0.0

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
                Slider(value: $sliderValue, in: 0 ... (item.audioDuration ?? 1), onEditingChanged: sliderEditingChanged)
                    .tint(.gray)

                if let duration = item.audioDuration, !duration.isNaN, !duration.isInfinite {
                    Text(formatter.string(from: duration) ?? "")
                        .foregroundStyle(.gray)
                }
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
        .onChange(of: voiceMessagePlayer.currentTime) { newValue in
            sliderValue = newValue.seconds
        }
    }

    private func sliderEditingChanged(editing: Bool) {
        if !editing {
            voiceMessagePlayer.seek(to: sliderValue)
        }
    }

    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }

    private var playButton: some View {
        Button {
            guard let audioURLString = item.audioURL, let url = URL(string: audioURLString) else { return }
            if voiceMessagePlayer.playbackState == .playing {
                voiceMessagePlayer.pauseAudio()
            } else {
                voiceMessagePlayer.playAudio(from: url)
            }
        } label: {
            Image(systemName: voiceMessagePlayer.playbackState == .playing ? "pause.fill" : "play.fill")
                .resizable()
                .frame(width: 12, height: 12)
                .padding(10)
                .background(item.direction == .received ? .green : .white)
                .clipShape(Circle())
                .foregroundStyle(item.direction == .received ? .white : .black)
        }
    }

    private var timeStampTextView: some View {
        Text(item.timeStamp.formatToTime)
            .font(.footnote)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ScrollView {
        BubbleAudioView(item: .receivedPlaceholder)
        BubbleAudioView(item: .sentPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
    .onAppear {
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
}
