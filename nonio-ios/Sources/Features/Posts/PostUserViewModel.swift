import Foundation

struct PostUserViewModel {
       
    var scoreString: String {
        "\(score) \(score > 1 ? "votes" : "vote")"
    }
    
    var dateString: String? {
        let df = DateFormatter.dateComponents
        return df.string(from: date, to: .now)
    }
    
    var commentString: String {
        "\(commentCount)"
    }
    
    let showCommentCount: Bool
    
    let user: String
    
    private let calendar: Calendar
    private let score: Int
    private let commentCount: Int
    private let date: Date
    
    init(
        comment: Comment,
        calendar: Calendar = .current
    ) {
        self.user = comment.user
        self.score = comment.upvotes
        self.commentCount = comment.upvotes
        self.date = comment.parsedDate
        self.calendar = .current
        self.showCommentCount = false
    }
    
    init(
        post: Post,
        calendar: Calendar = .current
    ) {
        self.user = post.user
        self.score = post.score
        self.commentCount = post.commentCount
        self.date = post.date
        self.calendar = calendar
        self.showCommentCount = true
    }
}
