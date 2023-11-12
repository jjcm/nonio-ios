import Foundation

struct PostUserViewModel {
    
    private let calendar: Calendar
    
    var scoreString: String {
        "\(post.score) \(post.score > 1 ? "scores" : "score")"
    }
    
    var dateString: String? {
        let df = DateFormatter.dateComponents
        return df.string(from: post.date, to: .now)
    }
    
    var commentString: String {
        "\(post.commentCount)"
    }
    
    let post: Post
    
    init(post: Post, calendar: Calendar = .current) {
        self.post = post
        self.calendar = calendar
    }
}
