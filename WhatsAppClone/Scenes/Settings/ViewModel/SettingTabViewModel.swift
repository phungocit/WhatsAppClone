//
//  SettingTabViewModel.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 7/8/24.
//

import AlertKit
import Combine
import Firebase
import PhotosUI
import SwiftUI

@MainActor
final class SettingTabViewModel: ObservableObject {
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachment?
    @Published var isShowProgressHUD = false
    @Published var isShowSuccessHUD = false

    var enableSaveButton: Bool {
        profilePhoto != nil
    }

    private(set) var progressHUDView = AlertAppleMusic17View(title: "Uploading profile photo", subtitle: nil, icon: .spinnerSmall)
    private(set) var successHUDView = AlertAppleMusic17View(title: "Profile info updated", subtitle: nil, icon: .done)
    private var subscription: AnyCancellable?

    init() {
        onPhotoPickerSelection()
    }

    func uploadProfilePhoto() {
        guard let profilePhoto = profilePhoto?.thumbnail else { return }
        isShowProgressHUD = true
        FirebaseHelper.uploadImage(profilePhoto, for: .profilePhoto) { [weak self] result in
            switch result {
            case let .success(imageUrl):
                self?.onUploadSuccess(imageUrl)
            case let .failure(error):
                print("Failed tot upload profile image to firebase storage:", error.localizedDescription)
            }
        } progressHandler: { _ in
        }
    }
}

extension SettingTabViewModel {
    private func onPhotoPickerSelection() {
        subscription = $selectedPhotoItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoItem in
                guard let photoItem else { return }
                self?.parsePhotoPickerItems(photoItem)
            }
    }

    private func parsePhotoPickerItems(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            self.profilePhoto = MediaAttachment(id: UUID().uuidString, type: .photo(uiImage))
        }
    }

    private func onUploadSuccess(_ imageUrl: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).child(.profileImageUrl).setValue(imageUrl.absoluteString)
        isShowProgressHUD = false
        progressHUDView.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.profilePhoto = nil
            self.selectedPhotoItem = nil
            self.isShowSuccessHUD = true
        }
    }
}
