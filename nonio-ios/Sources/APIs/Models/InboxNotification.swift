import Foundation

struct InboxNotification: Decodable, Hashable {
    let id: Int
    let comment_id: Int
    let date: Int
    /// refers to the post's url
    let post: String
    let post_title: String
    let content: String
    let user: String
    let upvotes: Int
    let downvotes: Int
    let parent: Int
    let edited: Bool
    let read: Bool
    let post_type: String
    let parent_content: String
}

extension InboxNotification {

    var postImageURL: URL? {
        guard postType == .image else { return nil }
        return ImageURLGenerator.thumbnailImageURL(path: post)
    }

    var postType: Post.ContentType? {
        .init(rawValue: post_type)
    }

    enum ReplyType {
        case post
        case comment(id: Int)
    }

    var replyType: ReplyType {
        parent > 0 ? .comment(id: parent) : .post
    }

    var isPostReply: Bool {
        if case .post = replyType {
            return true
        }
        return false
    }
}
