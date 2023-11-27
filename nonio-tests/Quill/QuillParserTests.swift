import XCTest
@testable import nonio_ios

class QuillParserTests: XCTestCase {
    
    func testParser() {
        let testJson = "{\"ops\":[{\"attributes\":{\"bold\":true},\"insert\":\"hello\"},{\"insert\":\" \"},{\"attributes\":{\"italic\":true},\"insert\":\"world\"},{\"insert\":\"\\n\"}]}"
        let result = QuillParser().parseQuillJS(json: testJson)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].content.string, "hello world")
    }
    
    func testQuote() {
        let testJson = "{\"ops\":[{\"insert\":\"this is a quote\"},{\"attributes\":{\"blockquote\":true},\"insert\":\"\\n\"}]}"
        let result = QuillParser().parseQuillJS(json: testJson)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].content.string, "this is a quote")
        XCTAssertTrue(result[0].isQuote)
    }
    
    func testInvalid() {
        let testJson = ""
        let result = QuillParser().parseQuillJS(json: testJson)
        XCTAssertEqual(result.count, 0)
    }
}

private extension AttributedString {
    var string: String {
        NSAttributedString(self).string
    }
}
