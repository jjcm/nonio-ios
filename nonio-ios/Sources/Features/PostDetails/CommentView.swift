import Foundation
import SwiftUI

struct CommentView: View {
    @ObservedObject var comment: CommentModel
    @ObservedObject var commentVotesViewModel: CommentVotesViewModel
    @State private var showHighlightedAnimation: Bool = false
    let showUpvoteCount: Bool
    let width: CGFloat
    let didTapOnURL: ((URL) -> Void)?
    let didTapUserProfileAction: ((String) -> Void)
    let animationEnded: (() -> Void)
    let showHighlightedAnimationValue: Bool

    init(
        comment: CommentModel,
        showUpvoteCount: Bool,
        width: CGFloat,
        commentVotesViewModel: CommentVotesViewModel,
        showHighlightedAnimation: Bool,
        didTapOnURL: ((URL) -> Void)?,
        didTapUserProfileAction: @escaping ((String) -> Void),
        animationEnded: @escaping (() -> Void)
    ) {
        self.comment = comment
        self.width = width
        self.commentVotesViewModel = commentVotesViewModel
        self.didTapOnURL = didTapOnURL
        self.showUpvoteCount = showUpvoteCount
        self.didTapUserProfileAction = didTapUserProfileAction
        self.showHighlightedAnimationValue = showHighlightedAnimation
        self.animationEnded = animationEnded
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
            }
            .padding(.horizontal, 16)

            Divider()
                .frame(height: 0.5)
                .background(UIColor.separator.color)
        }
        .background(showHighlightedAnimation ? UIColor.secondarySystemBackground.color : .clear)
        .onAppear {
            if showHighlightedAnimationValue {
                if #available(iOS 17.0, *) {
                    withAnimation(.easeInOut(duration: 0.6), completionCriteria: .removed) {
                        showHighlightedAnimation = true
                    } completion: {
                        showHighlightedAnimation = false
                        animationEnded()
                    }
                }
            }
        }
        .animation(.easeInOut, value: showHighlightedAnimation)
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
}

private extension CommentView {
    struct Layout {
        static let levelIndent: CGFloat = 20
    }
}
