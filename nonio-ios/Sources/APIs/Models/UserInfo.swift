import Foundation

struct UserInfo: Decodable {
    let comments: Int
    let description: String
    let karma: Int
    let posts: Int
    let comment_karma: Int
}
