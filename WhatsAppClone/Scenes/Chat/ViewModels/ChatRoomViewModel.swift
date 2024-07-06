//
//  ChatRoomViewModel.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 4/8/24.
//

import Combine
import Foundation
import PhotosUI
import SwiftUI

final class ChatRoomViewModel: ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    @Published var showPhotoPicker = false
    @Published var photoPickerItems = [PhotosPickerItem]()
    @Published var mediaAttachments = [MediaAttachment]()
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false, nil)
    @Published var isRecodingVoiceMessage = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    @Published var scrollToBottomRequest: (scroll: Bool, isAnimated: Bool) = (false, false)

    private(set) var channel: ChannelItem
    private var subscriptions = Set<AnyCancellable>()
    private var currentUser: UserItem?
    private let voiceRecorderService = VoiceRecorderService()

    var showPhotoPickerPreview: Bool {
        !mediaAttachments.isEmpty || !photoPickerItems.isEmpty
    }

    var disableSendButton: Bool {
        mediaAttachments.isEmpty && textMessage.isEmptyOrWhiteSpace
    }

    init(_ channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setUpVoiceRecorderListeners()
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
        voiceRecorderService.tearDown()
    }

    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            guard let self = self else { return }
            switch authState {
            case let .loggedIn(currentUser):
                self.currentUser = currentUser
                if self.channel.allMembersFetched {
                    self.getMessages()
                    print("channel members: \(channel.members.map { $0.username })")
                } else {
                    self.getAllChannelMembers()
                }
            default:
                break
            }
        }
        .store(in: &subscriptions)
    }

    private func setUpVoiceRecorderListeners() {
        voiceRecorderService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.isRecodingVoiceMessage = isRecording
            }
            .store(in: &subscriptions)

        voiceRecorderService.$elaspedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elapsedTime in
                self?.elapsedVoiceMessageTime = elapsedTime
            }
            .store(in: &subscriptions)
    }

    func sendMessage() {
        guard let currentUser else { return }
        if mediaAttachments.isEmpty {
            MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) { [weak self] in
                self?.textMessage = ""
                self?.scrollToBottom(isAnimated: true)
            }
        } else {
            sendMultipleMediaMessages(textMessage, attachments: mediaAttachments)
            clearTextInputArea()
        }
    }

    private func clearTextInputArea() {
        mediaAttachments.removeAll()
        photoPickerItems.removeAll()
        textMessage = ""
        UIApplication.dismissKeyboard()
    }

    private func sendMultipleMediaMessages(_ text: String, attachments: [MediaAttachment]) {
        mediaAttachments.forEach { attachment in
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: text, attachment)
            case .video:
                sendVideoMessage(text: text, attachment)
            case .audio:
                sendAudioMessage(text: text, attachment)
            }
        }
    }

    private func sendPhotoMessage(text: String, _ attachment: MediaAttachment) {
        // Upload the image to storage bucket
        uploadImageToStorage(attachment) { [weak self] imageURL in
            // Store the metadata to our database
            guard let self, let currentUser else { return }
            print("Uploaded image to Storage")
            let uploadParams = MessageUploadParams(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                thumbnailURL: imageURL.absoluteString,
                sender: currentUser
            )

            MessageService.sendMediaMessage(to: channel, params: uploadParams) {
                self.scrollToBottom(isAnimated: true)
            }
        }
    }

    private func sendVideoMessage(text: String, _ attachment: MediaAttachment) {
        // Upload the video to storage bucket
        uploadFileToStorage(for: .videoMessage, attachment) { [weak self] videoURL in
            // Upload the video thumbnail
            self?.uploadImageToStorage(attachment) { [weak self] thumbnailURL in
                guard let self, let currentUser else { return }

                let uploadParams = MessageUploadParams(
                    channel: self.channel,
                    text: text,
                    type: .video,
                    attachment: attachment,
                    thumbnailURL: thumbnailURL.absoluteString,
                    videoURL: videoURL.absoluteString,
                    sender: currentUser
                )
                MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                    self?.scrollToBottom(isAnimated: true)
                }
            }
        }
    }

    private func sendAudioMessage(text: String, _ attachment: MediaAttachment) {
        // Upload the audio to storage bucket
        uploadFileToStorage(for: .audioMessage, attachment) { [weak self] audioURL in
            guard let self, let currentUser, let audioDuration = attachment.audioDuration else { return }

            let uploadParams = MessageUploadParams(
                channel: self.channel,
                text: text,
                type: .audio,
                attachment: attachment,
                sender: currentUser,
                audioURL: audioURL.absoluteString,
                audioDuration: audioDuration
            )

            MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
        }
    }

    private func scrollToBottom(isAnimated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.isAnimated = isAnimated
    }

    private func uploadImageToStorage(_ attachment: MediaAttachment, completion: @escaping (_ imageURL: URL) -> Void) {
        FirebaseHelper.uploadImage(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
            case let .success(imageURL):
                completion(imageURL)
            case let .failure(error):
                print("Failed to upload image to Storage:", error.localizedDescription)
            }
        } progressHandler: { progress in
            print("UPLOAD IMAGE PROGRESS:", progress)
        }
    }

    private func uploadFileToStorage(
        for uploadType: FirebaseHelper.UploadType,
        _ attachment: MediaAttachment,
        completion: @escaping (_ fileURL: URL) -> Void
    ) {
        guard let fileURL = attachment.fileURL else { return }
        FirebaseHelper.uploadFile(for: uploadType, fileURL: fileURL) { result in
            switch result {
            case let .success(fileURL):
                completion(fileURL)
            case let .failure(error):
                print("Failed to upload file to Storage:", error.localizedDescription)
            }
        } progressHandler: { progress in
            print("UPLOAD FILE PROGRESS:", progress)
        }
    }

    private func getMessages() {
//        messages = dummyMessages
//        scrollToBottom(isAnimated: false)

        MessageService.getMessages(for: channel) { [weak self] messages in
            self?.messages = messages
            self?.scrollToBottom(isAnimated: false)
            print("messages: \(messages.map { $0.text })")
        }
    }

    private func getAllChannelMembers() {
        // I already have current user, and potentially 2 other members so no need to refetch those
        guard let currentUser = currentUser else { return }
        let membersAlreadyFetched = channel.members.compactMap { $0.uid }
        var memberUIDSToFetch = channel.membersUids.filter { !membersAlreadyFetched.contains($0) }
        memberUIDSToFetch = memberUIDSToFetch.filter { $0 != currentUser.uid }

        UserService.getUsers(with: memberUIDSToFetch) { [weak self] userNode in
            guard let self = self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getMessages()
            print("getAllChannelMembers: \(channel.members.map { $0.username })")
        }
    }

    func handleTextInputArea(_ action: TextInputAreaView.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecorder()
        }
    }

    private func toggleAudioRecorder() {
        if voiceRecorderService.isRecording {
            // Stop recording
            voiceRecorderService.stopRecording { [weak self] audioURL, audioDuration in
                self?.createAudioAttachment(from: audioURL, audioDuration)
            }
        } else {
            voiceRecorderService.startRecording()
        }
    }

    private func createAudioAttachment(from audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL = audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }

    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self = self else { return }

            let audioRecordings = mediaAttachments.filter { $0.type == .audio(.stubURL, .stubTimeInterval) }
            self.mediaAttachments = audioRecordings
            Task {
                await self.parsePhotoPickerItems(photoItems)
            }
        }
        .store(in: &subscriptions)
    }

    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for photoItem in photoPickerItems {
            if photoItem.isVideo {
                if let movie = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self), let thumbnailImage = try? await movie.url.generateVideoThumbnail(), let itemIdentifier = photoItem.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnailImage, movie.url))
                    mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try? await photoItem.loadTransferable(type: Data.self),
                    let thumbnail = UIImage(data: data),
                    let itemIdentifier = photoItem.itemIdentifier
                else { return }
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
                mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }

    func dismissMediaPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
    }

    func showMediaPlayer(_ fileURL: URL) {
        videoPlayerState.show = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }

    func handleMediaAttachmentPreview(_ action: MediaAttachmentPreview.UserAction) {
        switch action {
        case let .play(attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediaPlayer(fileURL)
        case let .remove(attachment):
            remove(attachment)
            guard let fileURL = attachment.fileURL else { return }
            if attachment.type == .audio(.stubURL, .stubTimeInterval) {
                voiceRecorderService.deleteRecording(at: fileURL)
            }
        }
    }

    private func remove(_ item: MediaAttachment) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == item.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)

        guard let photoIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == item.id }) else { return }
        photoPickerItems.remove(at: photoIndex)
    }

    func isNewDay(for message: MessageItem, at index: Int) -> Bool {
        let priorIndex = max(0, index - 1)
        let priorMessage = messages[priorIndex]
        return !message.timeStamp.isSameDay(as: priorMessage.timeStamp)
    }

    private var dummyMessages: [MessageItem] {
        [
            MessageItem(id: "1", isGroupChat: false, text: "", type: .admin(AdminMessageType.channelCreation), ownerUid: "1", timeStamp: ISO8601DateFormatter().date(from: "2024-06-20 01: 55: 28 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: nil, audioDuration: nil),
            MessageItem(id: "2", isGroupChat: false, text: "66", type: .text, ownerUid: "2", timeStamp: ISO8601DateFormatter().date(from: "2024-06-20 01: 56: 11 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: nil, audioDuration: nil), MessageItem(id: "3", isGroupChat: false, text: "88", type: .text, ownerUid: "3", timeStamp: ISO8601DateFormatter().date(from: "2024-06-20 01: 56: 18 +0000") ?? Date(), sender: nil, thumbnailUrl: nil, thumbnailWidth: nil, thumbnailHeight: nil, videoURL: nil, audioURL: nil, audioDuration: nil),
            MessageItem(id: "4", isGroupChat: false, text: "", type: .photo, ownerUid: "4", timeStamp: ISO8601DateFormatter().date(from: "2024-06-20 01: 58: 12 +0000") ?? Date(), sender: nil, thumbnailUrl: "https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?cs=srgb&dl=pexels-francesco-ungaro-96938.jpg&fm=jpg", thumbnailWidth: 667.0, thumbnailHeight: 1000.0, videoURL: nil, audioURL: nil, audioDuration: nil),
            MessageItem(id: "5", isGroupChat: false, text: "", type: .photo, ownerUid: "5", timeStamp: ISO8601DateFormatter().date(from: "2024-06-20 01: 58: 56 +0000") ?? Date(), sender: nil, thumbnailUrl: "https://images.pexels.com/photos/96938/pexels-photo-96938.jpeg?cs=srgb&dl=pexels-francesco-ungaro-96938.jpg&fm=jpg", thumbnailWidth: 4288.0, thumbnailHeight: 2848.0, videoURL: nil, audioURL: nil, audioDuration: nil),
        ]
    }
}
