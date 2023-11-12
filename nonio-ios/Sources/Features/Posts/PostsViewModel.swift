import Foundation
import Moya
import Combine
import CombineMoya
import UIKit

class PostsViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
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
    private let provider = MoyaProvider<NonioAPI>(plugins: [NetworkLoggerPlugin()])
    private var cancellables: Set<AnyCancellable> = []
    
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
}
