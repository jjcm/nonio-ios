import SwiftUI
import AVKit

struct PostVideoPlayerView: View {
    var url: URL
    private let player: AVPlayer
    @State private var playerLayer: AVPlayerLayer = .init()
    
    init(url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
    }

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                player.play()
            }
            .onDisappear {
                player.pause()
                player.replaceCurrentItem(with: nil)
            }
    }
}
