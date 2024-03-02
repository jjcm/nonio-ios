import Foundation
import Moya
import Combine
import CombineMoya

class InboxViewModel: ObservableObject {
    @Published private(set) var models: [InboxNotification] = []
    @Published private(set) var loading = true
    @Published private(set) var unreadCountUpdated: Int?
    private let provider = MoyaProvider.defaultProvider
    private var cancellables: Set<AnyCancellable> = []
    private let parser = QuillParser()

    func fetch() {
        loading = true
        provider.requestPublisher(.getNotifications(unread: nil))
            .map([InboxNotification].self, atKeyPath: "notifications")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    // TODO: show error
                    break
                }
                self.loading = false
            }, receiveValue: { models in
                self.unreadCountUpdated = models.filter { !$0.read }.count
                self.models = models.filter { !$0.shouldHide }
            })
            .store(in: &cancellables)
    }

    func markAsReadIfNeeded(notification: InboxNotification) {
        guard !notification.read else { return }

        provider.requestPublisher(.markNotificationRead(id: notification.id))
            .map(Bool.self)
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] result in
                if result {
                    self?.fetch()
                }
            }
            .store(in: &cancellables)
    }

    func toQuillRenderObject(model: InboxNotification) -> [QuillViewRenderObject] {
        var style = DefaultQuillStyle()
        style.textColor = model.read ? .secondaryLabel : .label
        let parser = QuillParser(style: style)
        return parser.parseQuillJS(json: model.content)
    }
}

extension InboxNotification {

    var shouldHide: Bool {
        post_title.isEmpty || post.isEmpty || content.isEmpty
    }

    var userViewModel: PostUserViewModel {
        let type: PostUserViewModel.ModelType
        switch replyType {
        case .post:
            type = .post
        case .comment:
            type = .comment
        }
        return .init(post: .make(from: self), showCommentCount: false, modelType: type, read: read)
    }

    var commentVotesViewModel: CommentVotesViewModel {
        .init(postURL: post)
    }
}
