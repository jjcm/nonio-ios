import Foundation

struct Tag: Codable, Hashable {
    let tag: String
    let count: Int
}

extension Tag {
    static let all = Tag(tag: "All", count: 1)
}
