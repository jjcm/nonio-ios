import Combine
import Foundation
import Moya

public protocol TokenRefreshServiceType {
    var isFetching: AnyPublisher<Bool, Never> { get }
    var tokenRefreshed: AnyPublisher<Void, Never> { get }
    func refreshTokenIfNeeded() -> AnyPublisher<Void, MoyaError>
}

class TokenRefreshService: TokenRefreshServiceType {
    private let provider: MoyaProvider<NonioAPI>
    private let keychainService: KeychainService
    private let tokenRefreshedSubject = PassthroughSubject<Void, Never>()
    private let isFetchingSubject = CurrentValueSubject<Bool, Never>(false)

    public private(set) lazy var isFetching = isFetchingSubject.eraseToAnyPublisher()
    public private(set) lazy var tokenRefreshed = tokenRefreshedSubject.eraseToAnyPublisher()

    init(
        provider: MoyaProvider<NonioAPI>,
        keychainService: KeychainService = KeychainService()
    ) {
        self.provider = provider
        self.keychainService = keychainService
    }

    public func refreshTokenIfNeeded() -> AnyPublisher<Void, MoyaError> {
        guard !isFetchingSubject.value else {
            return .value(())
        }

        guard let user = try? keychainService.getUser() else {
            return .value(())
        }

        isFetchingSubject.send(true)

        return fetchToken(token: user.refreshToken)
            .map { [weak self] _ in
                self?.isFetchingSubject.send(false)
                self?.tokenRefreshedSubject.send(())
            }
            .mapError { [weak self] error in
                self?.isFetchingSubject.send(false)
                self?.clean()
                return error
            }
            .handleEvents(receiveCancel: { [weak self] in
                self?.isFetchingSubject.send(false)
                self?.clean()
            })
            .eraseToAnyPublisher()
    }

    func fetchToken(token: String) -> AnyPublisher<Void, MoyaError> {
        return provider.requestPublisher(.refreshAccessToken(refreshToken: token))
            .map(TokenRefreshResponse.self)
            .map { [weak self] response in
                try? self?.keychainService.updateAccessToken(response.accessToken, refreshToken: response.refreshToken)
            }
            .eraseToAnyPublisher()
    }

    func clean() {
        try? keychainService.deleteUser()
    }
}
