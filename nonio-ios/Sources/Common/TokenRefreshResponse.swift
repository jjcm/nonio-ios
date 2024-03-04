import Foundation

struct TokenRefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
