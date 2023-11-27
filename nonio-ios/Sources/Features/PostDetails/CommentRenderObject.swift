import Foundation

struct CommentModel: Identifiable {
    var id: Int {
        comment.id
    }
    let comment: Comment
    var children: [Comment] = []
    let parser = QuillParser()
    
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
