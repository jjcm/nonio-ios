import Foundation
import SwiftUI
import SwipeActions

struct CommentView: View {
    @ObservedObject var comment: CommentModel
    @ObservedObject var commentVotesViewModel: CommentVotesViewModel
    let showUpvoteCount: Bool
    let width: CGFloat
    let didTapOnURL: ((URL) -> Void)?
    let didTapUserProfileAction: ((String) -> Void)
    let replyAction: ((CommentModel) -> Void)
    
    init(
        comment: CommentModel,
        showUpvoteCount: Bool,
        width: CGFloat,
        commentVotesViewModel: CommentVotesViewModel,
        didTapOnURL: ((URL) -> Void)?,
        didTapUserProfileAction: @escaping ((String) -> Void),
        replyAction: @escaping ((CommentModel) -> Void)
    ) {
        self.comment = comment
        self.width = width
        self.commentVotesViewModel = commentVotesViewModel
        self.didTapOnURL = didTapOnURL
        self.showUpvoteCount = showUpvoteCount
        self.didTapUserProfileAction = didTapUserProfileAction
        self.replyAction = replyAction
    }
    
    var body: some View {
        SwipeViewGroup {
            VStack(alignment: .leading, spacing: 0) {
               userAndContent
                
                Group {
                    ForEach(comment.children) { childComment in
                        CommentView(
                            comment: childComment,
                            showUpvoteCount: showUpvoteCount,
                            width: width - Layout.levelIndent,
                            commentVotesViewModel: commentVotesViewModel,
                            didTapOnURL: didTapOnURL,
                            didTapUserProfileAction: didTapUserProfileAction,
                            replyAction: replyAction
                        )
                        .padding(.leading, Layout.levelIndent)
                    }
                }
                .showIf(!comment.isCollapsed)
            }
        }
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
            withAnimation {
                if !comment.isLeaf {
                    comment.isCollapsed.toggle()
                }
            }
        }
    }
    
    var userAndContent: some View {
        SwipeView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    userRow
                        .padding(.top, 8)
                    
                    QuillContentView(
                        contents: comment.toQuillRenderObject(comment: comment.comment),
                        contentWidth: width,
                        didTapOnURL: didTapOnURL
                    )
                    .padding(.vertical, 12)
                }
                .padding(.trailing, 16)
                
                Divider()
                    .frame(height: 0.5)
                    .background(UIColor.separator.color)
            }

        } trailingActions: { _ in
            SwipeAction {
                replyAction(comment)
            } label: { highlight in
                Icon(image: R.image.replyDown.image, size: .medium)
                    .tint(UIColor.label.color)
            } background: { highlight in
                UIColor(red: 0.04, green: 0.52, blue: 1, alpha: 1).color.opacity(highlight ? 0.7 : 1.0)
            }
        }
        .swipeActionCornerRadius(0)
        .swipeSpacing(0)
        .swipeActionsMaskCornerRadius(0)
    }
}

private extension CommentView {
    struct Layout {
        static let levelIndent: CGFloat = 20
    }
}
