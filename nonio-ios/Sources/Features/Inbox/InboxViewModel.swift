import Foundation
import Moya
import Combine
import CombineMoya

class InboxViewModel: ObservableObject {
    @Published private(set) var models: [InboxNotification] = []
    @Published private(set) var loading = true
    private let provider = MoyaProvider.defaultProvider
    private var cancellables: Set<AnyCancellable> = []

    func fetch() {
        loading = true
        provider.requestPublisher(.getNotifications(unread: nil))
            .map([InboxNotification].self, atKeyPath: "notifications")
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
            }, receiveValue: { models in
                self.models = models
            })
            .store(in: &cancellables)
    }
}
