import Foundation
import Moya

extension MoyaProvider where Target == NonioAPI {
    static let keychainService = KeychainService()
    static let defaultProvider = MoyaProvider<NonioAPI>(
        plugins: [NetworkLoggerPlugin(), AccessTokenPlugin(tokenClosure: { target in
            guard let token = try? keychainService.getUser()?.accessToken else {
                return ""
            }
            return token
        })]
    )
}
