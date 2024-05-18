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
    
    var actionText: String? {
        switch modelType {
        case .user:
            return nil
        case .comment:
            return "replied to your post"
        case .post:
            return "replied to your comment"
        }
    }

    var read: Bool = false

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
        self.modelType = .user
    }
    
    init(
        post: Post,
        showUpvoteCount: Bool = true,
        showCommentCount: Bool = true,
        calendar: Calendar = .current,
        modelType: ModelType = .user,
        read: Bool = false
    ) {
        self.user = post.user
        self.commentCount = post.commentCount
        self.date = post.date
        self.calendar = calendar
        self.showCommentCount = showCommentCount
        self.showUpvoteCount = showUpvoteCount
        self.upvotesString = "\(post.score) \(post.score > 1 ? "votes" : "vote")"
        self.modelType = modelType
        self.read = read
    }
}
