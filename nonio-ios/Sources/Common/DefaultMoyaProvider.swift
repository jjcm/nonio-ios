import Foundation
import Moya
import Combine

enum NonioNetworkError: LocalizedError {
    case unknowError
}

class NonioProvider {

    static let `default`: DefaultMoyaProvider<NonioAPI> = DefaultMoyaProvider<NonioAPI>(
        keychainService: KeychainService(),
        tokenRefreshService: TokenRefreshService(provider: .default)
    )
}

class DefaultMoyaProvider<T> where T: AuthTargetType {
    let provider: MoyaProvider<T>
    let keychainService: KeychainServiceType
    let tokenRefreshService: TokenRefreshServiceType
    init(
        provider: MoyaProvider<T> = .default,
        keychainService: KeychainServiceType,
        tokenRefreshService: TokenRefreshServiceType
    ) {
        self.provider = provider
        self.keychainService = keychainService
        self.tokenRefreshService = tokenRefreshService
    }

    func requestPublisher(_ target: T, shouldRetry: Bool = true) -> AnyPublisher<Response, MoyaError> {
        return tokenRefreshService.isFetching
            .filter { !$0 }
            .setFailureType(to: MoyaError.self)
            .eraseToAnyPublisher()
            .flatMap(weak: self) { prov, _ in
                prov.provider.requestPublisher(target)
            }
            .tryCatch { error -> AnyPublisher<Response, MoyaError> in
                if case .underlying(_, let response) = error,
                   response?.statusCode == 401 {
                    return .value(Response(statusCode: 401, data: Data()))
                } else {
                    throw error
                }
             }
            .mapError { ($0 as? MoyaError) ?? MoyaError.underlying(NonioNetworkError.unknowError, nil)}
            .flatMap(weak: self) { prov, response -> AnyPublisher<Response, MoyaError> in
                guard
                    response.statusCode == 401,
                    shouldRetry,
                    target.needAuthenticate
                else {
                    return .value(response)
                }

                return prov.refreshToken()
                    .flatMap(weak: self) { prov, _ in
                        prov.requestPublisher(target, shouldRetry: false)
                    }
                    .eraseToAnyPublisher()
            }
            .first()
            .eraseToAnyPublisher()
    }

    func refreshToken() -> AnyPublisher<Void, MoyaError> {
        return tokenRefreshService.refreshTokenIfNeeded()
    }

    func requestWithProgressPublisher(_ target: T, callbackQueue: DispatchQueue? = nil) -> AnyPublisher<ProgressResponse, MoyaError> {
        provider.requestWithProgressPublisher(target, callbackQueue: callbackQueue)
    }
}


extension MoyaProvider where Target == NonioAPI {
    static let `default` = MoyaProvider<NonioAPI>(
        plugins: [NetworkLoggerPlugin(), AccessTokenPlugin(tokenClosure: { target in
            guard let token = try? KeychainService().getUser()?.accessToken else {
                return ""
            }
            return token
        })]
    )
}

extension Response {
    // Custom validation function
    func validateCustomStatusCode() throws -> Response {
        return self
    }
}
