import XCTest
@testable import nonio_ios

final class QuillJSContentTests: XCTestCase {
    func testIsBlock() {
        let op1 = QuillOperation(insert: "test")
        XCTAssertFalse(op1.isBlock)
        
        let op2 = QuillOperation(insert: "\n", attributes: nil)
        XCTAssertFalse(op2.isBlock)
        
        let op3 = QuillOperation(insert: "\n", attributes: .init())
        XCTAssertTrue(op3.isBlock)
    }
}
