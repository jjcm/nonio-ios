import Foundation
import Starscream

enum VideoResolution: String, CaseIterable, Comparable {
    case p480 = "480p"
    case p720 = "720p"
    case p1080 = "1080p"
    case p1440 = "1440p"
    case p2160 = "4k"

    private var sortOrder: Int {
        switch self {
        case .p480:
            return 0
        case .p720:
            return 1
        case .p1080:
            return 2
        case .p1440:
            return 3
        case .p2160:
            return 4
        }
    }

    static func < (lhs: VideoResolution, rhs: VideoResolution) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

struct EncodingProgress: Identifiable {

    let id = UUID()
    let resolution: VideoResolution
    let progress: Double
    let isSource: Bool

    var finished: Bool {
        progress >= 100.0
    }

    init(
        _ resolution: VideoResolution,
        _ progress: Double,
        _ isSource: Bool
    ) {
        self.resolution = resolution
        self.progress = progress
        self.isSource = isSource
    }
}

protocol VideoEncodingManagerDelegate: AnyObject {
    func didUpdateProgress(_ progress: EncodingProgress)
    func encodeDidFinish()
}

class VideoEncodingManager: WebSocketDelegate {
    private var socket: WebSocket?
    private(set) var sourceResolution: VideoResolution?

    weak var delegate: VideoEncodingManagerDelegate?

    let server: URL
    init(server: URL) {
        self.server = server
    }

    func connect(filename: String) {
        var url = server.appendingPathComponent("encode")
        url.append(queryItems: [.init(name: "file", value: filename)])
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }

    private func handleWebSocketMessageEvent(text: String) {
        let message = text.split(separator: ":")
        if message.count < 2 { return }

        let resolutionString = String(message[0])
        let progress = String(message[1])

        if resolutionString == "resolution" {
            let resolution = progress.split(separator: "x")
            guard resolution.count == 2,
                  let width = Int(resolution[0]),
                  let height = Int(resolution[1]) else { return }

            let resolutionValue = min(width, height)
            self.sourceResolution = VideoResolution(rawValue: "\(resolutionValue)p")
        } else if resolutionString.matches(regex: "source|480p|720p|1080p|1280p|1440p|4k") {
            let resolution = resolutionString == "source" ? self.sourceResolution : VideoResolution(rawValue: resolutionString)
            let progressValue = Double(progress) ?? 0
            if let resolution {
                updateProgress(for: resolution, progress: progressValue)
            } else {
                debugPrint("Resolution \(resolutionString) not supported")
            }

            if resolutionString == "source" && progressValue >= 100 {
                encodeFinish()
            }
        }
    }

    private func updateProgress(for resolution: VideoResolution, progress: Double) {
        delegate?.didUpdateProgress(
            EncodingProgress(
                resolution,
                progress,
                false
            )
        )
    }

    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .text(let text):
            receiveText(text)
        default:
            break
        }
    }

    func receiveText(_ text: String) {
        handleWebSocketMessageEvent(text: text)
    }

    func encodeFinish() {
        delegate?.encodeDidFinish()
    }
}

private extension String {
    func matches(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

