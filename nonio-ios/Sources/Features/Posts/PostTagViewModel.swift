import Foundation
import Moya
import Combine

final class PostTagViewModel: ObservableObject {
    @Published private(set) var tags: [PostTag]
    @Published private(set) var votes: [Vote]
        
    let post: String
    let provider = NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []
    private var votingMap: [Int: Bool] = [:]

    init(post: String, tags: [PostTag], votes: [Vote]) {
        self.post = post
        self.tags = tags
        self.votes = votes
    }
    
    func isVoted(tag: PostTag) -> Bool {
        votes.contains(where: { $0.tagID == tag.tagID && $0.postID == tag.postID })
    }
    
    func toggleVote(tag: PostTag, vote: Bool) {
        if votingMap[tag.tagID] == true {
            // return if request is loading
            return
        }
        
        updateLoading(tag: tag, loading: true)

        if vote {
            addVote(tag: tag)
        } else {
            removeVote(tag: tag)
        }
    }
    
    private func addVote(tag: PostTag) {
        provider.requestPublisher(.addVote(post: post, tag: tag.tag))
            .map(Vote.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { vote in
                self.updateLoading(tag: tag, loading: false)
                self.tags = self.tags.map { old in
                    var newTag = old
                    if newTag.tagID == tag.tagID {
                        newTag.score += 1
                    }
                    return newTag
                }
                self.votes.append(vote)
            })
            .store(in: &cancellables)
    }
    
    private func removeVote(tag: PostTag) {
        provider.requestPublisher(.removeVote(post: post, tag: tag.tag))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                self.updateLoading(tag: tag, loading: false)
                self.votes.removeAll(where: { $0.tagID == tag.tagID })
                self.tags = self.tags.map { old in
                    var newTag = old
                    if newTag.tagID == tag.tagID {
                        newTag.score -= 1
                    }
                    return newTag
                }
            })
            .store(in: &cancellables)
    }
    
    private func updateLoading(tag: PostTag, loading: Bool) {
        votingMap[tag.tagID] = loading
    }
}

