import SwiftUI
import PhotosUI
import AVKit
import Kingfisher

struct MediaView: View {
    let media: PostSubmissionMediaType

    var body: some View {
        GeometryReader { geometry in
            switch media.type {
            case .image:
                KFImage(ImageURLGenerator.imageURL(path: media.fileName))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
            case .video:
                VideoPlayerView(url: ImageURLGenerator.videoURL(path: (media.fileName as NSString).deletingPathExtension))
                    .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
            }
        }
    }
}
