import Foundation
import Combine
import Moya

class NotificationUnreadTicker: ObservableObject {
    @Published private(set) var unreadCount: Int = 0

    private let provider = NonioProvider.default
    private var cancellables = Set<AnyCancellable>()
    private let notificationCenter: NotificationCenter

    private static let initialTickerInterval: TimeInterval = 10
    // Start checking every 10s
    private var exponentialBackoff: TimeInterval = initialTickerInterval
    // Max 30 minutes
    private static let maxTickerInterval: TimeInterval = 1800

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        setupTicker()
        setupNotifications()
    }

    func updateCount(_ count: Int) {
        unreadCount = count
    }

    func resetInterval() {
        exponentialBackoff = Self.initialTickerInterval
        cancellables.removeAll()
        setupTicker()
    }
}

private extension NotificationUnreadTicker {

    func setupTicker() {
        Timer.publish(every: exponentialBackoff, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in
                self.fetch()
            }
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let failure) = completion {
                    self?.increaseInterval()
                }
            }, receiveValue: { [weak self] count in
                self?.unreadCount = count
            })
            .store(in: &cancellables)
    }

    func fetch() -> AnyPublisher<Int, MoyaError> {
        provider.requestPublisher(.getNotificationsUnreadCount)
            .map(Int.self)
            .eraseToAnyPublisher()
    }

    func setupNotifications() {
        notificationCenter.addObserver(forName: .UserDidLogin, object: nil, queue: nil) { [weak self] _ in
            self?.resetInterval()
        }
        notificationCenter.addObserver(forName: .UserDidSendPost, object: nil, queue: nil) { [weak self] _ in
            self?.resetInterval()
        }
        notificationCenter.addObserver(forName: .UserDidSendComment, object: nil, queue: nil) { [weak self] _ in
            self?.resetInterval()
        }
    }

    func increaseInterval() {
        exponentialBackoff = min(exponentialBackoff * 1.3, Self.maxTickerInterval)
        cancellables.removeAll()
        setupTicker()
    }
}
