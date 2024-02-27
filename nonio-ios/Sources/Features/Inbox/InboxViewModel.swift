import Foundation
import Moya
import Combine
import CombineMoya

class InboxViewModel: ObservableObject {
    @Published private(set) var models: [InboxNotification] = []
    @Published private(set) var loading = true
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
                self.models = models
            })
            .store(in: &cancellables)
    }

    func toQuillRenderObject(content: String) -> [QuillViewRenderObject] {
        parser.parseQuillJS(json: content)
    }
}

extension InboxNotification {

    var userViewModel: PostUserViewModel {
        let type: PostUserViewModel.ModelType
        switch replyType {
        case .post:
            type = .post
        case .comment:
            type = .comment
        }
        return .init(post: .make(from: self), showCommentCount: false, modelType: type)
    }

    var commentVotesViewModel: CommentVotesViewModel {
        .init(postURL: post)
    }
}
