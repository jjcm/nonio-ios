import Foundation

struct InboxNotification: Decodable {
    let id: Int
    let comment_id: Int
    let date: Int
    /// refers to the post's url
    let post: String
    let postTitle: String
    let content: String
    let user: String
    let upvotes: Int
    let downvotes: Int
    let parent: Int
    let edited: Bool
    let read: Bool
}

