import Foundation
import UIKit
import Combine
import SwiftUI

final class PostViewModel: ObservableObject {
    let post: Post
    
    var title: String {
        post.title
    }
    
    var imageURL: URL {
        ImageURLGenerator.thumbnailImageURL(path: post.url)
    }
    
    var linkString: String {
        post.link?.absoluteString ?? ""
    }
    
    var shouldShowImage: Bool {
        post.type == .image
    }
    
    var shouldShowLink: Bool {
        post.link != nil
    }
    
    var imageSize: CGSize {
        let ratio = 0.45
        return .init(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width * ratio
        )
    }

    @Published var tags: [PostTag] = []
    private let provider = NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []

    init(post: Post) {
        self.post = post
        self.tags = post.tags
    }

    func addTag(_ tag: String) {
        provider.requestPublisher(.postTagCreate(post: post.url, tag: tag))
            .map(PostTagCreateResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                self.tags.insert(.init(postID: post.ID, tag: tag, tagID: response.tagID, score: 1), at: 0)
            })
            .store(in: &cancellables)
    }
}
