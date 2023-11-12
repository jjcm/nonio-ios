import Foundation
import UIKit

struct PostViewModel {
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
        if post.type == .image || post.type == .link {
            return true
        }
        return false
    }
    
    var shouldShowLink: Bool {
        post.link != nil
    }
    
    var shouldShowTags: Bool {
        !post.tags.isEmpty
    }
    
    var imageSize: CGSize {
        let ratio = 0.45
        return .init(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width * ratio
        )
    }
    
    init(post: Post) {
        self.post = post
    }
}
