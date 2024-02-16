import Foundation
import Moya
import Combine

final class CommentEditorViewModel: ObservableObject {
    private let provider: MoyaProvider<NonioAPI> = .defaultProvider
    private var cancellables: Set<AnyCancellable> = []
    @Published private(set) var loading = false
    private(set) var error: MoyaError?
    @Published var showError = false
    
    let post: Post
    let comment: Comment?
    let addCommentSuccess: (Comment) -> Void
    init(
        post: Post,
        comment: Comment?,
        addCommentSuccess: @escaping (Comment) -> Void
    ) {
        self.post = post
        self.comment = comment
        self.addCommentSuccess = addCommentSuccess
    }
    
    func addComment(content: String) {
        guard !loading else { return }
        loading = true
        provider.requestPublisher(
            .addComment(
                content: content,
                post: post.url,
                parent: comment?.id
            )
        )
        .map(Comment.self, using: .default)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] result in
            switch result {
            case .finished:
                self?.showError = false
            case .failure(let failure):
                self?.error = failure
                self?.showError = true
            }
            self?.loading = false
        }, receiveValue: { [weak self] comment in
            self?.addCommentSuccess(comment)
        })
        .store(in: &cancellables)
    }
}
