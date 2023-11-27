import Foundation

struct Tag: Decodable, Hashable {
    let tag: String
    let count: Int
}

extension Tag {
    static let all = Tag(tag: "All", count: 1)
}
