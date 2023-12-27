import Foundation

final class PostUserViewModel: ObservableObject {

    var dateString: String? {
        let df = DateFormatter.dateComponents
        return df.string(from: date, to: .now)
    }
    
    var commentString: String {
        "\(commentCount)"
    }
    
    var commentID: Int?
    let showCommentCount: Bool
    let showUpvoteCount: Bool
    
    let user: String
    var upvotesString: String?
    
    private let calendar: Calendar
    private let commentCount: Int
    private let date: Date
    
    init(
        comment: Comment,
        upvotesString: String,
        showUpvoteCount: Bool,
        calendar: Calendar = .current
    ) {
        self.user = comment.user
        self.upvotesString = upvotesString
        self.commentCount = comment.upvotes
        self.date = comment.parsedDate
        self.calendar = .current
        self.showCommentCount = false
        self.showUpvoteCount = showUpvoteCount
        self.commentID = comment.id
    }
    
    init(
        post: Post,
        showUpvoteCount: Bool,
        calendar: Calendar = .current
    ) {
        self.user = post.user
        self.commentCount = post.commentCount
        self.date = post.date
        self.calendar = calendar
        self.showCommentCount = true
        self.showUpvoteCount = showUpvoteCount
        self.upvotesString = "\(post.score) \(post.score > 1 ? "votes" : "vote")"
    }
}
