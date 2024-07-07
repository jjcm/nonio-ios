import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var url: URL
    private let player: AVPlayer
    @State private var playerLayer: AVPlayerLayer = .init()
    @State private var isMuted: Bool = false
    private var currentTime: Double = 0
    private var duration: Double = 0
    @State private var currentText: String = ""

    init(url: URL) {
        self.url = url
        self.player = AVPlayer(url: url)
    }

    var body: some View {
        ZStack {
            VideoPlayer(player: player)

            VStack {
                Spacer()
                HStack {
                    Text(currentText)
                        .foregroundColor(.white)
                        .font(.system(size: 13))
                        .padding(.leading)
                    Spacer()
                    Button {
                        isMuted.toggle()
                        player.isMuted = isMuted
                    } label: {
                        Icon(image: Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.2.fill"), size: .big)
                            .foregroundColor(.white)
                            .padding(.trailing)
                    }
                }
                .padding(.bottom)
            }
        }
        .onLoad {
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            player.play()

            addPeriodicTimeObserver()
        }
    }

    private func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1.0, preferredTimescale: timeScale)

        player.addPeriodicTimeObserver(forInterval: time, queue: .main) { time in
            if player.currentItem?.status == .readyToPlay,
               let total = self.player.currentItem?.duration.seconds {
                self.currentText = timeString(from: time.seconds) + " / " + timeString(from: total)
            }
        }
    }

    private func timeString(from seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


#Preview {
    VideoPlayerView(url: URL(string: "https://video.non.io/upload-video.mp4")!)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
}
