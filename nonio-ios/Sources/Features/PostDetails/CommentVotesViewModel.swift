import Foundation
import Moya
import Combine

final class CommentVotesViewModel: ObservableObject {
    
    @Published private(set) var commentVotes: [CommentVote] = []
    private var votingMap: [Int: Bool] = [:]
    private let provider: MoyaProvider<NonioAPI> = .defaultProvider
    private var cancellables: Set<AnyCancellable> = []
    
    let postURL: String
    init(postURL: String) {
        self.postURL = postURL
    }
    
    func fetchCommentVotes(hasLoggedIn: Bool) {
        if !hasLoggedIn {
            commentVotes = []
            return
        }
        
        provider.requestPublisher(.getCommentVotes(post: postURL))
            .map([CommentVote].self, atKeyPath: "commentVotes")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { commentVotes in
                self.commentVotes = commentVotes
            })
            .store(in: &cancellables)
    }
    
    func voteComment(comment: CommentModel, vote: Bool) {
        provider.requestPublisher(.addCommentVote(commentID: comment.id, vote: vote))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                self.updateLoading(commentID: comment.id, loading: false)
                comment.upvotes = comment.comment.upvotes + 1
                self.commentVotes.append(.init(comment_id: comment.id, upvote: true))
            })
            .store(in: &cancellables)
    }
    
    func isCommentVoted(comment: Int?) -> Bool {
        commentVotes.contains(where: { $0.comment_id == comment && $0.upvote })
    }
        
    private func updateLoading(commentID: Int, loading: Bool) {
        votingMap[commentID] = loading
    }
}
