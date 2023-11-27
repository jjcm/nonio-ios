import Foundation

struct Comment: Identifiable, Decodable {
    let id: Int
    let date: Double
    let post: String
    let postTitle: String
    let content: String
    let user: String
    let upvotes: Int
    let downvotes: Int
    let parent: Int
    let lineageScore: Int
    let descendentCommentCount: Int
    let edited: Bool

    var parsedDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(date) / 1000)
    }
}
