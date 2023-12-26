import Foundation

struct Post: Codable {
    let ID: Int
    let title: String
    let user: String
    let time: Double
    let url: String
    let link: URL?
    let content: String
    let type: ContentType?
    let score: Int
    let commentCount: Int
    let tags: [PostTag]
    let width: CGFloat?
    let height: CGFloat?
    
    let date: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ID = try container.decode(Int.self, forKey: .ID)
        self.title = try container.decode(String.self, forKey: .title)
        self.user = try container.decode(String.self, forKey: .user)
        self.time = try container.decode(Double.self, forKey: .time)
        self.url = try container.decode(String.self, forKey: .url)
        self.link = try? container.decodeIfPresent(URL.self, forKey: .link)
        self.content = try container.decode(String.self, forKey: .content)
        self.type = try container.decodeIfPresent(Post.ContentType.self, forKey: .type)
        self.score = try container.decode(Int.self, forKey: .score)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
        self.tags = try container.decode([PostTag].self, forKey: .tags)
        self.width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
        self.height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
        self.date = Date(timeIntervalSince1970: time / 1000)
    }
    
    init(
        id: Int,
        title: String,
        user: String,
        time: Double,
        url: String,
        link: URL?,
        type: ContentType,
        content: String,
        score: Int,
        commentCount: Int,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        tags: [PostTag],
        date: Date = .now
    ) {
        self.ID = id
        self.title = title
        self.user = user
        self.time = time
        self.date = date
        self.url = url
        self.link = link
        self.type = type
        self.content = content
        self.score = score
        self.commentCount = commentCount
        self.width = width
        self.height = height
        self.tags = tags
    }
}

extension Post: Hashable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.ID == rhs.ID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ID)
    }
}

extension Post {
    enum ContentType: String, Codable {
        case image, text, link, video, html, blog
    }  
}

struct PostTag: Codable {
    let postID: Int
    let tag: String
    let tagID: Int
    let score: Int
}
