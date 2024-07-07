import Foundation
import Moya
import Combine
import SwiftUI

final class PostTagViewModel: ObservableObject {
    let provider = NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []
    private var votingMap: [Int: Bool] = [:]
    
    @Published private(set) var errorMessage: String?
    @Published var tags: [PostTag]

    init(tags: [PostTag]) {
        self.tags = tags
    }

    func isVoted(tag: PostTag, service: UserVotingService) -> Bool {
        service.isVoted(tag: tag) == true
    }

    func toggleVote(post: String?, tag: PostTag, vote: Bool, service: UserVotingService) {
        guard let post else { return }
        if votingMap[tag.tagID] == true {
            // return if request is loading
            return
        }
        
        updateLoading(tag: tag, loading: true)

        if vote {
            addVote(post: post, tag: tag, servcie: service)
        } else {
            removeVote(post: post, tag: tag, servcie: service)
        }
    }

    private func addVote(post: String, tag: PostTag, servcie: UserVotingService) {
        provider.requestPublisher(.addVote(post: post, tag: tag.tag))
            .map(Vote.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.handleError(result)
                self?.updateLoading(tag: tag, loading: false)
            }, receiveValue: { [weak self] vote in
                guard let self else { return }
                self.tags = self.tags.map { old in
                    var newTag = old
                    if newTag.tagID == tag.tagID {
                        newTag.score += 1
                    }
                    return newTag
                }
                servcie.addVote(vote)
            })
            .store(in: &cancellables)
    }
    
    private func removeVote(post: String, tag: PostTag, servcie: UserVotingService) {
        provider.requestPublisher(.removeVote(post: post, tag: tag.tag))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.handleError(result)
                self?.updateLoading(tag: tag, loading: false)
            }, receiveValue: { [weak self] _ in
                guard let self else { return }

                self.tags = self.tags.map { old in
                    var newTag = old
                    if newTag.tagID == tag.tagID {
                        newTag.score -= 1
                    }
                    return newTag
                }
                .filter({ $0.score > 0 })
                servcie.remoteVote(tag)
            })
            .store(in: &cancellables)
    }
    
    private func updateLoading(tag: PostTag, loading: Bool) {
        votingMap[tag.tagID] = loading
    }

    private func handleError(_ result: Subscribers.Completion<MoyaError>) {
        switch result {
        case .finished:
            break
        case .failure(let failure):
            errorMessage = failure.errorMessage
        }
    }
}

