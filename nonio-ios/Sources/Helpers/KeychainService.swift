import KeychainAccess
import Foundation

protocol KeychainServiceType {
    func saveUser(_ user: LoginResponse) throws
    func getUser() throws -> LoginResponse?
    func deleteUser() throws
}

final class KeychainService: KeychainServiceType {
    private let keychain = Keychain(service: "com.nonio-ios.keychain")
    private let userKey = "current-user-key"

    func saveUser(_ user: LoginResponse) throws {
        let userData = try JSONEncoder().encode(user)
        try keychain.set(userData, key: userKey)
    }

    func getUser() throws -> LoginResponse? {
        guard let userData = try keychain.getData(userKey) else { return nil }
        let user = try JSONDecoder().decode(LoginResponse.self, from: userData)
        return user
    }

    func deleteUser() throws {
        try keychain.remove(userKey)
    }

    func updateAccessToken(_ token: String, refreshToken: String) throws {
        guard let user = try getUser() else { return }
        try saveUser(
            .init(
                accessToken: token,
                refreshToken: refreshToken,
                username: user.username
            )
        )
    }
}
