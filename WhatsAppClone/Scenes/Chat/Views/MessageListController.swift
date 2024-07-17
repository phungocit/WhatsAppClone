//
//  MessageListController.swift
//  WhatsAppClone
//
//  Created by Phil Tran on 3/14/24.
//

import Combine
import Foundation
import SwiftUI
import UIKit

final class MessageListController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        messageCollectionView.backgroundColor = .clear
        view.backgroundColor = .clear
        setUpViews()
        setUpMessageListeners()
    }

    init(_ viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    private let viewModel: ChatRoomViewModel
    private var subscriptions = Set<AnyCancellable>()
    private let cellIdentifier = "MessageListControllerCells"
    private var lastScrollPosition: String?

    private let compositionalLayout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .gray.withAlphaComponent(0.2)
        listConfig.showsSeparators = false
        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        section.interGroupSpacing = -12
        return section
    }

    private let backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(image: .chatBackground)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    }()

    private lazy var pullToRefresh: UIRefreshControl = {
        let pullToRefresh = UIRefreshControl()
        pullToRefresh.transform = CGAffineTransformMakeScale(0.75, 0.75)
        pullToRefresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return pullToRefresh
    }()

    private lazy var messageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.refreshControl = pullToRefresh
        return collectionView
    }()

    private let pullDownHUDView: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfig)
        let font = UIFont.systemFont(ofSize: 12, weight: .black)

        buttonConfig.image = image
        buttonConfig.baseBackgroundColor = .bubbleGreen
        buttonConfig.baseForegroundColor = .whatsAppBlack
        buttonConfig.imagePadding = 5
        buttonConfig.cornerStyle = .capsule

        buttonConfig.attributedTitle = AttributedString("Pull down", attributes: AttributeContainer([NSAttributedString.Key.font: font]))
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()

    // MARK: Methods
    private func setUpViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(messageCollectionView)
        view.addSubview(pullDownHUDView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            messageCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            messageCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messageCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            pullDownHUDView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pullDownHUDView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setUpMessageListeners() {
        let delay = 200

        viewModel.$messages
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.messageCollectionView.reloadData()
            }
            .store(in: &subscriptions)

        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messageCollectionView.scrollToLastItem(at: .bottom, animated: scrollRequest.isAnimated)
                }
            }
            .store(in: &subscriptions)

        viewModel.$isPaginating
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] isPaginating in
                guard let self, let lastScrollPosition else { return }
                if !isPaginating {
                    guard let index = viewModel.messages.firstIndex(where: { $0.id == lastScrollPosition }) else { return }
                    let indexPath = IndexPath(item: index, section: 0)
                    self.messageCollectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.pullToRefresh.endRefreshing()
                }
            }
            .store(in: &subscriptions)
    }

    @objc private func refreshData() {
        lastScrollPosition = viewModel.messages.first?.id
//        messageCollectionView.refreshControl?.endRefreshing()
        viewModel.paginateMoreMessages()
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource
extension MessageListController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        let message = viewModel.messages[indexPath.item]
        let isNewDay = viewModel.isNewDay(for: message, at: indexPath.item)
        let isShowSenderName = viewModel.isShowSenderName(for: message, at: indexPath.item)
        cell.contentConfiguration = UIHostingConfiguration {
            BubbleView(message: message, channel: viewModel.channel, isNewDay: isNewDay, isShowSenderName: isShowSenderName)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIApplication.dismissKeyboard()
        let messageItem = viewModel.messages[indexPath.row]
        switch messageItem.type {
        case .video:
            guard let videoURLString = messageItem.videoURL, let url = URL(string: videoURLString) else { return }
            viewModel.showMediaPlayer(url)
        default: break
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            pullDownHUDView.alpha = viewModel.isPaginatable ? 1 : 0
        } else {
            pullDownHUDView.alpha = 0
        }
    }
}

private extension UICollectionView {
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard numberOfItems(inSection: numberOfSections - 1) > 0 else { return }

        let lastSectionIndex = numberOfSections - 1
        let lastRowIndex = numberOfItems(inSection: lastSectionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        scrollToItem(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}

#Preview {
    MessageListView(ChatRoomViewModel(.placeholder))
        .ignoresSafeArea()
}
