//
//  BubbleView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 6/7/24.
//

import SwiftUI

struct BubbleView: View {
    let message: MessageItem
    let channel: ChannelItem
    let isNewDay: Bool
    let isShowSenderName: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isNewDay {
                newDayTimeStampTextView
                    .padding()
            }
            if isShowSenderName {
                senderNameTextView
            }
            composeDynamicBubbleView
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var composeDynamicBubbleView: some View {
        switch message.type {
        case .text:
            BubbleTextView(item: message)
        case .video, .photo:
            BubbleImageView(item: message)
        case .audio:
            BubbleAudioView(item: message)
        case let .admin(adminType):
            switch adminType {
            case .channelCreation:
                newDayTimeStampTextView
                ChannelCreationTextView()
                    .padding()
                if channel.isGroupChat {
                    AdminMessageTextView(channel: channel)
                }
            default:
                Text("UNKNOW")
            }
        }
    }

    private var newDayTimeStampTextView: some View {
        Text(message.timeStamp.relativeDateString)
            .font(.caption)
            .bold()
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.whatsAppGray)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }

    private var senderNameTextView: some View {
        Text(message.sender?.username ?? "Unknown 🤷‍♂️")
            .lineLimit(1)
            .foregroundStyle(.gray)
            .font(.footnote)
            .padding(.bottom, 2)
            .padding(.horizontal)
            .padding(.leading, 20)
    }
}

#Preview {
    BubbleView(message: .receivedPlaceholder, channel: .placeholder, isNewDay: false, isShowSenderName: false)
}
