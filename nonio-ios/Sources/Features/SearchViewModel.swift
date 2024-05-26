import Foundation
import Combine
import Moya

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var tags: [Tag] = []
    private let showCreateNewTag: Bool
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var loading = true
    private let provider = MoyaProvider<NonioAPI>(plugins: [NetworkLoggerPlugin()])

    init(showCreateNewTag: Bool) {
        self.showCreateNewTag = showCreateNewTag
        $searchText
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.performSearch(with: searchText)
            }
            .store(in: &cancellables)
    }

    func isCreateNewTag(index: Int) -> Bool {
        showCreateNewTag && index == 0
    }
}

private extension SearchViewModel {
    func performSearch(with searchText: String) {
        loading = true
        provider.requestPublisher(.getTags(query: searchText))
            .map([Tag].self, atKeyPath: "tags")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    break
                }
                self.loading = false
            }, receiveValue: { tags in
                self.reloadTags(tags)
                self.loading = false
            })
            .store(in: &cancellables)
      }

    func reloadTags(_ tags: [Tag]) {
        var tags = tags
        if showCreateNewTag {
            tags.insert(Tag(tag: "create new tag", count: 0), at: 0)
        }
        self.tags = tags
    }
}
