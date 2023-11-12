import XCTest
@testable import nonio_ios

final class PostsViewModelTests: XCTestCase {
    
    func testDisplayTag() {
        let vm = PostsViewModel()
        XCTAssertEqual(vm.displayTag, "#ALL")
        XCTAssertEqual(vm.currentTag, .all)
        XCTAssertEqual(vm.getPostParams, .all)
        
        let testTag = Tag(tag: "test", count: 0)
        vm.onSelectTag(testTag)
        XCTAssertEqual(vm.displayTag, "#TEST")
        XCTAssertEqual(vm.currentTag, testTag)
    }
    
    func testSelectAllPosts() {
        let vm = PostsViewModel()
        vm.onSelectTag(Tag(tag: "test", count: 0))
        
        vm.onSelectAllPosts()
        XCTAssertEqual(vm.currentTag, .all)
    }
    
    func testSelectTag() {
        let vm = PostsViewModel()
        let selectTag = Tag(tag: "tag", count: 1)
        
        vm.onSelectTag(selectTag)
        XCTAssertEqual(vm.currentTag, selectTag)
        XCTAssertEqual(vm.getPostParams.tag, vm.currentTag.tag)
    }
    
    func testSelectTime() {
        let vm = PostsViewModel()
        let day = GetPostParams.Time.day
        
        vm.onSelectTimeframe(day)
        XCTAssertEqual(vm.getPostParams.time, day)
    }
}
