import Foundation

struct ImageURLGenerator {
    static func thumbnailImageURL(path: String) -> URL {
        Constants.ThumbnailBaseURL.appending(path: "\(path).webp")
    }
    
    static func userAvatarURL(user: String) -> URL {
        Constants.AvatarBaseURL.appending(path: "\(user).webp")
    }
}
