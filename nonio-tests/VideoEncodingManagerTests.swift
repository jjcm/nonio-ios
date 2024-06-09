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
        XCTAssertEqual(manager.sourceResolution, .p720)
    }

    func testProgress() {
        let delegate = VideoEncodingManagerDelegateMock()
        manager.delegate = delegate

        manager.sendText("480p:0.8")
        XCTAssertEqual(delegate.videoProgress?.resolution, .p480)
        XCTAssertEqual(delegate.videoProgress?.progress, 0.8)
    }

    func testEncodeDidFinish() {
        let delegate = VideoEncodingManagerDelegateMock()
        manager.delegate = delegate

        XCTAssertFalse(delegate.encodeDidFinished)

        manager.sendText("source:99.9")
        XCTAssertFalse(delegate.encodeDidFinished)

        manager.sendText("source:100")
        XCTAssertTrue(delegate.encodeDidFinished)
    }
}

extension VideoEncodingManager {
    func sendText(_ text: String) {
        receiveText(text)
    }
}


class VideoEncodingManagerDelegateMock: VideoEncodingManagerDelegate {

    var videoProgress: EncodingProgress?
    var encodeDidFinished: Bool = false

    func didUpdateProgress(_ progress: EncodingProgress) {
        videoProgress = progress
    }

    func encodeDidFinish() {
        encodeDidFinished = true
    }
}
