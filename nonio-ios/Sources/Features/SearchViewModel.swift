import Foundation
import Combine
import Moya

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var tags: [Tag] = []
    @Published var selectedTag: Tag?
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var loading = true
    private let provider = MoyaProvider<NonioAPI>(plugins: [NetworkLoggerPlugin()])

    init() {
        $searchText
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.performSearch(with: searchText)
            }
            .store(in: &cancellables)
    }

    private func performSearch(with searchText: String) {
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
                self.tags = tags
                self.loading = false
            })
            .store(in: &cancellables)
      }
}
