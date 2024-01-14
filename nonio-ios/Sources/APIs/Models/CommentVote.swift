import Foundation

struct CommentVote: Decodable {
    let comment_id: Int
    let upvote: Bool
}
