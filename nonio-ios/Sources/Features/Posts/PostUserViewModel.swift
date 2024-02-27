import Foundation

final class PostUserViewModel: ObservableObject {

    enum ModelType {
        case user
        case comment
        case post
    }

    let modelType: ModelType

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
    
    var userText: String {
        switch modelType {
        case .user:
            return user
        case .comment:
            return "\(user) replied to your post"
        case .post:
            return "\(user) replied to your comment"
        }
    }

    var isReply: Bool {
        switch modelType {
        case .user:
            return false
        case .comment, .post:
            return true
        }
    }

    var upvotesString: String?
    
    private let calendar: Calendar
    private let commentCount: Int
    private let date: Date
    let user: String

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
        self.modelType = .comment
    }
    
    init(
        post: Post,
        showUpvoteCount: Bool = true,
        showCommentCount: Bool = true,
        calendar: Calendar = .current,
        modelType: ModelType = .user
    ) {
        self.user = post.user
        self.commentCount = post.commentCount
        self.date = post.date
        self.calendar = calendar
        self.showCommentCount = showCommentCount
        self.showUpvoteCount = showUpvoteCount
        self.upvotesString = "\(post.score) \(post.score > 1 ? "votes" : "vote")"
        self.modelType = modelType
    }
}
