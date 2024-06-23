import Foundation
import SwiftUI

struct CommentView: View {
    @ObservedObject var comment: CommentModel
    @ObservedObject var commentVotesViewModel: CommentVotesViewModel
    let showUpvoteCount: Bool
    let width: CGFloat
    let didTapOnURL: ((URL) -> Void)?
    let didTapUserProfileAction: ((String) -> Void)

    init(
        comment: CommentModel,
        showUpvoteCount: Bool,
        width: CGFloat,
        commentVotesViewModel: CommentVotesViewModel,
        didTapOnURL: ((URL) -> Void)?,
        didTapUserProfileAction: @escaping ((String) -> Void)
    ) {
        self.comment = comment
        self.width = width
        self.commentVotesViewModel = commentVotesViewModel
        self.didTapOnURL = didTapOnURL
        self.showUpvoteCount = showUpvoteCount
        self.didTapUserProfileAction = didTapUserProfileAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                userRow
                    .padding(.top, 8)

                let leading = Layout.levelIndent * CGFloat(comment.level)
                let contentWidth = width - leading
                QuillContentView(
                    contents: comment.toQuillRenderObject(comment: comment.comment),
                    contentWidth: contentWidth,
                    didTapOnURL: didTapOnURL
                )
                .padding(.leading, leading)
                .padding(.vertical, 12)
                .showIf(!comment.isCollapsed)
            }
            .padding(.horizontal, 16)

            Divider()
                .frame(height: 0.5)
                .background(UIColor.separator.color)
        }
        .showIf(!comment.hide)
    }

    var userRow: some View {
        PostUserView(
            viewModel: .init(
                comment: comment.comment,
                upvotesString: comment.upvotesString,
                showUpvoteCount: showUpvoteCount
            ),
            commentVotesViewModel: commentVotesViewModel,
            isCollapsed: comment.isCollapsed,
            didTapUserProfileAction: {
                didTapUserProfileAction(comment.comment.user)
            }
        ) {
            commentVotesViewModel.voteComment(comment: comment, vote: true)
        }
        .padding(.bottom, 14)
        .contentShape(Rectangle())
        .onLongPressGesture {
            if !comment.isLeaf {
                comment.isCollapsed.toggle()
            }
        }
    }
}

private extension CommentView {
    struct Layout {
        static let levelIndent: CGFloat = 20
    }
}

#Preview {
    CommentView(
        comment: .init(
            comment: .init(
                id: 1,
                date: 1,
                post: "post",
                postTitle: "title",
                content: "{\"ops\":[{\"insert\":\"test comment\"},{\"attributes\":{\"blockquote\":true},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]}",
                user: "mike",
                upvotes: 10,
                downvotes: 1,
                parent: -1,
                lineageScore: 20,
                descendentCommentCount: 30,
                edited: false
            ),
            level: 1
        ),
        showUpvoteCount: true,
        width: UIScreen.main.bounds.width,
        commentVotesViewModel: .init(postURL: ""),
        didTapOnURL: {
            _ in
        },
        didTapUserProfileAction: { _ in }
    )
    .environmentObject(AppSettings())
}
