import Foundation

struct ImageURLGenerator {
    static func thumbnailImageURL(path: String) -> URL {
        Constants.ThumbnailBaseURL.appending(path: "\(path).webp")
    }
    
    static func userAvatarURL(user: String) -> URL {
        Constants.AvatarBaseURL.appending(path: "\(user).webp")
    }
    
    static func videoURL(path: String) -> URL {
        Constants.VideoBaseURL.appending(path: "\(path).mp4")
    }
    
    static func imageURL(path: String) -> URL {
        Constants.ImageBaseURL.appending(path: "\(path).webp")
    }
}
