//
//  SettingsViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by Phil Tran on 26/3/2024.
//

import Combine
import Firebase
import Foundation
import Kingfisher
import PhotosUI
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var profileImage = Image("no_profile")

    @Published var selectedImage: PhotosPickerItem? {
        didSet {
            Task {
                try await loadImage(fromItem: selectedImage)
            }
        }
    }

    private var uiImage: UIImage?

    @MainActor
    private func loadImage(fromItem item: PhotosPickerItem?) async throws {
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        profileImage = Image(uiImage: uiImage)
        try await updateProfileImage()
    }

    private func updateProfileImage() async throws {
        guard let image = uiImage else { return }
        guard let imageUrl = try? await ImageUploader.uploadImage(image) else { return }
        try await UserService.shared.updateUserProfileImage(withImageUrl: imageUrl)
    }
}
