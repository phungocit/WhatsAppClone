//
//  ChatViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 20/3/2024.
//

import AVFoundation
import Combine
import Foundation
import PhotosUI
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var count = 0
    @Published var messageText = ""
    @Published var isRecording = false
    @Published var isEmoji = false
    @Published var audioRecorder: AVAudioRecorder!
    @Published var recordingURL: URL?
    @Published var messageGroups = [MessageGroup]()
    @Published var messageImage = Image("")
    @Published var createVideoUrl: URL?

    @Published var selectedImage: PhotosPickerItem? {
        didSet {
            Task {
                try await loadImage(fromItem: selectedImage)
            }
        }
    }

    @Published var selectedVideo: PhotosPickerItem? {
        didSet {
            Task {
                try await loadVideo()
            }
        }
    }

    let service: ChatService

    private var videoData: Data?
    private var uiImage: UIImage?
    private var cancellables = Set<AnyCancellable>()

    init(user: User) {
        service = ChatService(chatPartner: user)
        observeMessages()
        service.$count.sink { [weak self] count in
            self?.count = count
        }
        .store(in: &cancellables)
    }

    @MainActor
    func loadVideo() async throws {
        guard let item = selectedVideo else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        videoData = data
        try await updateMessageVideo()
    }

    func observeMessages() {
        service.observeMessages { messages in
            let groupedMessages = self.groupMessagesByDate(messages: messages)

            DispatchQueue.main.async {
                for group in groupedMessages {
                    if let existingGroupIndex = self.messageGroups.firstIndex(where: { $0.date == group.date }) {
                        self.messageGroups[existingGroupIndex].messages.append(contentsOf: group.messages)
                    } else {
                        self.messageGroups.append(group)
                    }
                    self.count += 1
                }
            }
        }
    }

    func sendMessage(isImage: Bool?, isVideo: Bool?, isAudio: Bool?) {
        service.sendMessage(messageText, isImage: isImage, isVideo: isVideo, isAudio: isAudio)
        count += 1
    }

    @MainActor
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)

            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()

            isRecording = true
            recordingURL = audioFilename
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    @MainActor
    func stopRecording() {
        audioRecorder.stop()
        isRecording = false
        updateMessageAudio()
    }
}

private extension ChatViewModel {
    private func loadImage(fromItem item: PhotosPickerItem?) async throws {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        messageImage = Image(uiImage: uiImage)
        try await updateMessageImage()
    }

    private func updateMessageImage() async throws {
        guard let image = uiImage else { return }
        guard let imageUrl = try? await ImageUploader.uploadMessageImage(image) else { return }
        service.sendMessage(imageUrl, isImage: true, isVideo: false, isAudio: false)
    }

    private func updateMessageVideo() async throws {
        guard let videoData = videoData else { return }
        guard let videoUrl = try await VideoUploader.uploadVideo(data: videoData) else { return }
        service.sendMessage(videoUrl, isImage: false, isVideo: true, isAudio: false)
    }

    private func updateMessageAudio() {
        // guard let audioUrl = try await AudioUploader.uploadAudio(recordingURL: recordingURL) else { return }

        AudioUploader.uploadAudio(recordingURL: recordingURL) { [weak self] audioUrl in
            if let audioURL = audioUrl {
                self?.service.sendMessage(audioURL, isImage: false, isVideo: false, isAudio: true)
            } else {
                print("failed to upload audio")
                return
            }
        }
    }

    private func groupMessagesByDate(messages: [Message]) -> [MessageGroup] {
        var groupedMessages = [Date: [Message]]()

        for message in messages {
            let messageDate = Calendar.current.startOfDay(for: message.timestamp.dateValue())

            if groupedMessages[messageDate] == nil {
                groupedMessages[messageDate] = [message]
            } else {
                groupedMessages[messageDate]?.append(message)
            }
            DispatchQueue.main.async {
                self.count += 1
            }
        }

        return groupedMessages.map { date, messages in
            let sortedMessages = messages.sorted { $0.timestamp.dateValue() < $1.timestamp.dateValue() }
            return MessageGroup(date: date, messages: sortedMessages)
        }
        .sorted { $0.date < $1.date }
    }
}
