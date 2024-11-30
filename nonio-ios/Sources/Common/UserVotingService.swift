import Foundation
import Combine

class UserVotingService: ObservableObject {
    @Published private(set) var votes: [Vote] = []
    private let provider = NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []


    func isVoted(tag: PostTag) -> Bool {
        votes.contains(where: { $0.tagID == tag.tagID && $0.postID == tag.postID })
    }

    func addVote(_ vote: Vote) {
        votes.append(vote)
    }

    func remoteVote(_ tag: PostTag) {
        votes.removeAll(where: {
            $0.tagID == tag.tagID && $0.postID == tag.postID
        })
    }

    func fetchVotes() {
        provider.requestPublisher(.getVotes)
            .map([Vote].self, atKeyPath: "votes")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { votes in
                self.votes = votes
            })
            .store(in: &cancellables)
    }
}
