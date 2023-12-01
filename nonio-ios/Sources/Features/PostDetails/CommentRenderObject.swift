import Foundation

final class CommentModel: Identifiable, ObservableObject {
    var id: Int {
        comment.id
    }
    let comment: Comment
    let parser = QuillParser()
    
    var children: [CommentModel] = []
    @Published var isCollapsed = false
    
    init(
        comment: Comment,
        parser: QuillParser = .init()
    ) {
        self.comment = comment
    }
    
    func toQuillRenderObject(comment: Comment) -> [QuillViewRenderObject] {
        parser.parseQuillJS(json: comment.content)
    }
}
