import XCTest
@testable import nonio_ios

final class VideoEncodingManagerTests: XCTestCase {

    let url = URL(string: "http://a.com")!
    var manager: VideoEncodingManager!

    override func setUp() {
        super.setUp()
        manager = VideoEncodingManager(server: url)
    }

    func testSource() {
        let delegate = VideoEncodingManagerDelegateMock()
        manager.delegate = delegate

        manager.sendText("resolution:1280x720")
        XCTAssertEqual(manager.equivalentResolution, "1280p")
    }

    func testProgress() {
        let delegate = VideoEncodingManagerDelegateMock()
        manager.delegate = delegate

        manager.sendText("480p:0.8")
        XCTAssertEqual(delegate.videoProgress?.0, "480p")
        XCTAssertEqual(delegate.videoProgress?.1, 0.8)
    }
}

extension VideoEncodingManager {
    func sendText(_ text: String) {
        receiveText(text)
    }
}


class VideoEncodingManagerDelegateMock: VideoEncodingManagerDelegate {

    /// video resolution and it's progress
    var videoProgress: (String, Double)?

    func didUpdateProgress(resolution: String, progress: Double) {
        videoProgress = (resolution, progress)
    }
}
