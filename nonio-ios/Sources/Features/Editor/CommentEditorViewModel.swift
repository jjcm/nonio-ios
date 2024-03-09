import Foundation
import Moya
import Combine

final class CommentEditorViewModel: ObservableObject {
    private let provider = NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []
    @Published private(set) var loading = false
    private(set) var error: MoyaError?
    @Published var showError = false
    
    let postURL: String
    let comment: Comment?
    let addCommentSuccess: (Comment) -> Void
    init(
        postURL: String,
        comment: Comment?,
        addCommentSuccess: @escaping (Comment) -> Void
    ) {
        self.postURL = postURL
        self.comment = comment
        self.addCommentSuccess = addCommentSuccess
    }
    
    func addComment(content: String) {
        guard !loading else { return }
        loading = true
        provider.requestPublisher(
            .addComment(
                content: content,
                post: postURL,
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
