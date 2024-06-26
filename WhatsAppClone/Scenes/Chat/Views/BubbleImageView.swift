//
//  BubbleImageView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/15/24.
//

import Kingfisher
import SwiftUI

struct BubbleImageView: View {
    let item: MessageItem

    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if item.direction == .sent {
                Spacer()
            }

            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl, size: .mini)
                    .offset(y: 5)
            }

            messageImageView
                .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
                .overlay {
                    playButton
                        .opacity(item.type == .video ? 1 : 0)
                }
                .contextMenu {
                    Button {} label: {
                        Label("ContextMenu", systemImage: "heart")
                    }
                }


            if item.direction == .received {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
    }

    private var playButton: some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundStyle(.gray)
            .background(.thinMaterial)
            .clipShape(Circle())
    }

    private var messageImageView: some View {
        VStack(alignment: .leading, spacing: 0) {
            KFImage(URL(string: item.thumbnailUrl ?? ""))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: item.imageSize.width, height: item.imageSize.height)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemGray5))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.systemGray5))
                )
                .padding(5)
                .overlay(alignment: .bottomTrailing) {
                    timeStampTextView
                }

            if !item.text.isEmptyOrWhiteSpace {
                Text(item.text)
                    .padding([.horizontal, .bottom], 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: item.imageSize.width)
            }
        }
        .background(item.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .applyTail(item.direction)
    }

    private var shareButton: some View {
        Button {} label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.gray)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
    }

    private var timeStampTextView: some View {
        HStack {
            Text("11:13 AM")
                .font(.system(size: 12))

            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
            }
        }
        .padding(.vertical, 2.5)
        .padding(.horizontal, 8)
        .foregroundStyle(.white)
        .background(Color(.systemGray3))
        .clipShape(Capsule())
        .padding(12)
    }
}

#Preview {
    ScrollView {
        BubbleImageView(item: .receivedPlaceholder)
        BubbleImageView(item: .sentPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.4))
}