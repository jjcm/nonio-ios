import Foundation

final class CommentModel: Identifiable, ObservableObject {
    @Published private(set) var comment: Comment
    @Published var isCollapsed = false
    @Published var upvotesString: String = ""
    
    var id: Int {
        comment.id
    }

    var isLeaf: Bool {
        children.isEmpty
    }

    let commentVotes: [CommentVote] = []
    let parser = QuillParser()
    var children: [CommentModel] = []
    var upvotes: Int = 0 {
        didSet {
            upvotesString = toVoteString(upvotes: comment.upvotes)
        }
    }
    
    init(
        comment: Comment,
        parser: QuillParser = .init()
    ) {
        self.comment = comment
        self.upvotes = comment.upvotes
        self.upvotesString = toVoteString(upvotes: comment.upvotes)
    }
    
    func toQuillRenderObject(comment: Comment) -> [QuillViewRenderObject] {
        parser.parseQuillJS(json: comment.content)
    }
    
    private func toVoteString(upvotes: Int) -> String {
        "\(upvotes) \(upvotes > 1 ? "votes" : "vote")"
    }
}
