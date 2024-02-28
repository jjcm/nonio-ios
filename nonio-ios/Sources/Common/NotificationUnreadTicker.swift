import Foundation
import Combine
import Moya

class NotificationUnreadTicker: ObservableObject {
    @Published private(set) var unreadCount: Int = 0

    private let provider = MoyaProvider.defaultProvider
    private var cancellables = Set<AnyCancellable>()
    private let tickerInterval: TimeInterval = 20

    init() {
        Timer.publish(every: tickerInterval, on: .main, in: .common)
            .autoconnect()
            .prepend(.now)
            .flatMap { _ in
                self.fetch()
            }
            .sink(receiveCompletion: { completion in

            }, receiveValue: { [weak self] count in
                self?.unreadCount = count
            })
            .store(in: &cancellables)
    }

    private func fetch() -> AnyPublisher<Int, MoyaError> {
        provider.requestPublisher(.getNotificationsUnreadCount)
            .map(Int.self)
            .eraseToAnyPublisher()
    }

    func updateCount(_ count: Int) {
        unreadCount = count
    }
}
