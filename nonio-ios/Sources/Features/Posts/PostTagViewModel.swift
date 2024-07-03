import Foundation
import Moya
import Combine

final class PostTagViewModel: ObservableObject {
    @Published private(set) var tags: [PostTag] = []

    let provider = NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []
    private var votingMap: [Int: Bool] = [:]

    var userVotingService: UserVotingService?

    init(tags: [PostTag]) {
        self.tags = tags
    }

    func isVoted(tag: PostTag, service: UserVotingService) -> Bool {
        service.isVoted(tag: tag) == true
    }

    func toggleVote(post: String?, tag: PostTag, vote: Bool) {
        guard let post else { return }
        if votingMap[tag.tagID] == true {
            // return if request is loading
            return
        }
        
        updateLoading(tag: tag, loading: true)

        if vote {
            addVote(post: post, tag: tag)
        } else {
            removeVote(post: post, tag: tag)
        }
    }

    private func addVote(post: String, tag: PostTag) {
        provider.requestPublisher(.addVote(post: post, tag: tag.tag))
            .map(Vote.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] vote in
                guard let self else { return }

                self.updateLoading(tag: tag, loading: false)
                self.tags = self.tags.map { old in
                    var newTag = old
                    if newTag.tagID == tag.tagID {
                        newTag.score += 1
                    }
                    return newTag
                }
                self.userVotingService?.addVote(vote)
            })
            .store(in: &cancellables)
    }
    
    private func removeVote(post: String, tag: PostTag) {
        provider.requestPublisher(.removeVote(post: post, tag: tag.tag))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] _ in
                guard let self else { return }

                self.updateLoading(tag: tag, loading: false)
                self.tags = self.tags.map { old in
                    var newTag = old
                    if newTag.tagID == tag.tagID {
                        newTag.score -= 1
                    }
                    return newTag
                }
                self.userVotingService?.remoteVote(tag)
            })
            .store(in: &cancellables)
    }
    
    private func updateLoading(tag: PostTag, loading: Bool) {
        votingMap[tag.tagID] = loading
    }
}

