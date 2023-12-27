import Foundation
import Moya
import Combine
import CombineMoya
import UIKit

class PostsViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var votes: [Vote] = []
    @Published private(set) var loading = true
    @Published private(set) var currentTag: Tag = .all {
        didSet {
            tagsViewModel.selectTag(currentTag)
        }
    }
    @Published private(set) var tagsViewModel = TagsViewModel()
    var displayTag: String {
        "#\(currentTag.tag.uppercased())"
    }
    private(set) var getPostParams: GetPostParams = .all
    private var cancellables: Set<AnyCancellable> = []
    let provider = MoyaProvider.defaultProvider
    
    func fetch() {
        loading = true
        provider.requestPublisher(.getPosts(getPostParams))
            .map([Post].self, atKeyPath: "posts")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching posts: \(error)")
                }
                self.loading = false
            }, receiveValue: { fetchedPosts in
                self.posts = fetchedPosts
            })
            .store(in: &cancellables)
    }
    
    func onSelectTag(_ tag: Tag) {
        currentTag = tag
        getPostParams = .init(tag: tag.tag, sort: nil, time: nil)
        fetch()
    }
    
    func onSelectAllPosts() {
        currentTag = .all
        getPostParams = .all
        fetch()
    }
    
    func onSelectSortOption(_ sortOption: GetPostParams.Sort) {
        getPostParams.sort = sortOption
        fetch()
    }
    
    func onSelectTimeframe(_ timeframe: GetPostParams.Time) {
        getPostParams.time = timeframe
        fetch()
    }
    
    func didTapPostLink(post: Post) {
        guard let url = post.link, UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, completionHandler: nil)
    }
    
    func fetchVotes(hasLoggedIn: Bool) {
        if !hasLoggedIn {
            votes = []
            return
        }
        
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
