import Foundation

struct LoginResponse: Codable, Equatable {
    let accessToken: String
    let refreshToken: String
    let username: String
}
