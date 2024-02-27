import Foundation

struct InboxRowViewModel {
    let notification: InboxNotification

    var userViewModel: PostUserViewModel {
        let type: PostUserViewModel.ModelType
        switch notification.replyType {
        case .post: 
            type = .post
        case .comment:
            type = .comment
        }
        return .init(post: .make(from: notification), showCommentCount: false, modelType: type)
    }
    var commentVotesViewModel: CommentVotesViewModel {
        .init(postURL: notification.post)
    }

    init(notification: InboxNotification) {
        self.notification = notification
    }
}

private extension Post {
    static func make(from notification: InboxNotification) -> Self {
        return .init(
            id: -1,
            title: notification.post_title,
            user: notification.user,
            time: Double(notification.date),
            url: notification.post,
            link: nil,
            type: .text,
            content: notification.content,
            score: notification.upvotes,
            commentCount: 0,
            tags: [],
            date: Date(timeIntervalSince1970: TimeInterval(notification.date / 1000))
        )
    }
}
