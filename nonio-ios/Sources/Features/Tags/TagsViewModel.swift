import Foundation
import Moya
import Combine
import CombineMoya

class TagsViewModel: ObservableObject {
    @Published private(set) var tags: [Tag] = []
    @Published private(set) var selected: Tag?
    @Published private(set) var loading = true
    private let provider = MoyaProvider<NonioAPI>(plugins: [NetworkLoggerPlugin()])
    private var cancellables: Set<AnyCancellable> = []
    
    func fetch() {
        loading = true
        provider.requestPublisher(.getTags)
            .map([Tag].self, atKeyPath: "tags")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    // TODO: show error
                    break
                }
                self.loading = false
            }, receiveValue: { tags in
                self.tags = tags
            })
            .store(in: &cancellables)
    }
    
    func isTagSelected(tag: Tag) -> Bool {
        tag == selected
    }
    
    func selectTag(_ tag: Tag) {
        selected = tag
    }
}
