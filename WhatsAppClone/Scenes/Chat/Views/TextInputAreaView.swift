//
//  TextInputAreaView.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/14/24.
//

import SwiftUI

struct TextInputAreaView: View {
    @Binding var textMessage: String
    @Binding var isRecording: Bool
    @Binding var elapsedTime: TimeInterval
    var disableSendButton: Bool
    let actionHandler: (_ action: UserAction) -> Void

    @State private var isPulsing = false

    private var isSendButtonDisable: Bool {
        disableSendButton || isRecording
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            imagePickerButton
                .padding(3)
                .disabled(isRecording)
                .grayscale(isRecording ? 0.8 : 0)

            audioRecorderButton

            if isRecording {
                audioSessionIndcatorView
            } else {
                messageTextField
            }

            sendMessageButton
                .disabled(isSendButtonDisable)
                .grayscale(isSendButtonDisable ? 0.8 : 0)
        }
        .padding(.bottom)
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .background(.whatsAppWhite)
        .animation(.spring, value: isRecording)
        .onChange(of: isRecording) { isRecording in
            if isRecording {
                withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }

    private var audioSessionIndcatorView: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .scaleEffect(isPulsing ? 1.8 : 1.0)

            Text("Recording Audio")
                .font(.callout)
                .lineLimit(1)

            Spacer()

            Text(elapsedTime.formatElapsedTime)
                .font(.callout)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .clipShape(Capsule())
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.blue.opacity(0.1))
        )
        .overlay(textViewBorder)
    }

    private var messageTextField: some View {
        TextField("", text: $textMessage, axis: .vertical)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(textViewBorder)
    }

    private var textViewBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color(.systemGray5), lineWidth: 1)
    }

    private var imagePickerButton: some View {
        Button {
            actionHandler(.presentPhotoPicker)
        } label: {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 22))
        }
    }

    private var audioRecorderButton: some View {
        Button {
            actionHandler(.recordAudio)
        } label: {
            Image(systemName: isRecording ? "square.fill" : "mic.fill")
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundStyle(.white)
                .padding(6)
                .background(isRecording ? .red : .blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
    }

    private var sendMessageButton: some View {
        Button {
            actionHandler(.sendMessage)
        } label: {
            Image(systemName: "arrow.up")
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .padding(6)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
}

extension TextInputAreaView {
    enum UserAction {
        case presentPhotoPicker
        case sendMessage
        case recordAudio
    }
}

#Preview {
    TextInputAreaView(textMessage: .constant(""), isRecording: .constant(false), elapsedTime: .constant(0), disableSendButton: false) { _ in }
}
