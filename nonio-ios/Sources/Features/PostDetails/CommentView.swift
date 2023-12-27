import Foundation
import SwiftUI

struct CommentView: View {
    @ObservedObject var comment: CommentModel
    @ObservedObject var commentVotesViewModel: CommentVotesViewModel
    let showUpvoteCount: Bool
    let width: CGFloat
    let didTapOnURL: ((URL) -> Void)?
    init(
        comment: CommentModel,
        showUpvoteCount: Bool,
        width: CGFloat,
        commentVotesViewModel: CommentVotesViewModel,
        didTapOnURL: ((URL) -> Void)?
    ) {
        self.comment = comment
        self.width = width
        self.commentVotesViewModel = commentVotesViewModel
        self.didTapOnURL = didTapOnURL
        self.showUpvoteCount = showUpvoteCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            userRow
            
            if comment.isCollapsed {
                Divider()
                    .frame(height: 0.5)
                    .background(UIColor.separator.color)
            }
            
            Group {
                QuillContentView(
                    contents: comment.toQuillRenderObject(comment: comment.comment),
                    contentWidth: width,
                    didTapOnURL: didTapOnURL
                )
                
                Divider()
                    .frame(height: 0.5)
                    .background(UIColor.separator.color)
                
                ForEach(comment.children) { childComment in
                    CommentView(
                        comment: childComment,
                        showUpvoteCount: showUpvoteCount,
                        width: width - Layout.levelIndent,
                        commentVotesViewModel: commentVotesViewModel,
                        didTapOnURL: didTapOnURL
                    )
                    .padding(.leading, Layout.levelIndent)
                }
            }
            .showIf(!comment.isCollapsed)
        }
        .padding(.vertical, 8)
    }
    
    var userRow: some View {
        PostUserView(
            viewModel: .init(
                comment: comment.comment,
                upvotesString: comment.upvotesString,
                showUpvoteCount: showUpvoteCount
            ), 
            commentVotesViewModel: commentVotesViewModel,
            isCollapsed: comment.isCollapsed
        ) {
            commentVotesViewModel.voteComment(comment: comment, vote: true)
        }
        .padding(.bottom, 14)
        .contentShape(Rectangle())
        .onLongPressGesture {
            withAnimation {
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
