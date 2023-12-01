import XCTest
@testable import nonio_ios

final class ImageURLTests: XCTestCase {
    func testImageURL() {
        XCTAssertEqual(
            ImageURLGenerator.thumbnailImageURL(path: "abc"),
            URL(string: "https://thumbnail.non.io/abc.webp")
        )
        XCTAssertEqual(
            ImageURLGenerator.userAvatarURL(user: "abc"),
            URL(string: "https://avatar.non.io/abc.webp")
        )
        XCTAssertEqual(
            ImageURLGenerator.videoURL(path: "abc"),
            URL(string: "https://video.non.io/abc.mp4")
        )
        XCTAssertEqual(
            ImageURLGenerator.imageURL(path: "abc"),
            URL(string: "https://image.non.io/abc.webp")
        )
    }
}
