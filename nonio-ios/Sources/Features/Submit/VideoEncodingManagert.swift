import Foundation
import Starscream

protocol VideoEncodingManagerDelegate: AnyObject {
    func didUpdateProgress(resolution: String, progress: Double)
}

class VideoEncodingManager: WebSocketDelegate {
    private var socket: WebSocket?
    private(set) var equivalentResolution: String = "480p"

    weak var delegate: VideoEncodingManagerDelegate?

    let server: URL
    init(server: URL) {
        self.server = server
    }

    func connect(filename: String) {
        var url = server.appendingPathComponent("encoding")
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

        let resolution = String(message[0])
        let progress = String(message[1])

        if resolution == "resolution" {
            let resolution = progress.split(separator: "x")
            guard resolution.count == 2,
                  let width = Int(resolution[0]),
                  let height = Int(resolution[1]) else { return }

            let resolutionValue = max(width, height)
            self.equivalentResolution = "\(resolutionValue)p"
        } else if resolution.matches(regex: "source|480p|720p|1080p|1440p|4k") {
            let resolution = resolution == "source" ? self.equivalentResolution : resolution
            let progressValue = Double(progress) ?? 0
            updateProgress(for: resolution, percent: progressValue)
        }
    }

//    private func updateResolution(resolution: Int) {
//        self.equivalentResolution = "480p"
//        let resolutionBreakpoints: [String: Int] = [
//            "480p": 0,
//            "720p": 1067,
//            "1080p": 1600,
//            "1440p": 2240,
//            "2160p": 3200,
//            "4320p": 5760
//        ]

//        for (res, breakpoint) in resolutionBreakpoints {
//            if resolution > breakpoint {
//                self.equivalentResolution = res
//                // Assuming you have a function to enable resolution in your UI
//                enableResolution(resolution: res)
//            }
//        }
//    }


    private func updateProgress(for resolution: String, percent: Double) {
        delegate?.didUpdateProgress(resolution: resolution, progress: percent)
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
}

private extension String {
    func matches(regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
}

