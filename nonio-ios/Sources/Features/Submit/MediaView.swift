import SwiftUI
import PhotosUI
import AVKit
import Kingfisher

struct MediaView: View {
    let media: NonioAPI.Media
    let url: URL

    var body: some View {
        GeometryReader { geometry in
            switch media.type {
            case .image:
                KFImage(url)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
            case .video:
                VideoPlayerView(url: url)
                    .frame(width: geometry.size.width, height: geometry.size.width * 0.6)
            }
        }
    }
}
