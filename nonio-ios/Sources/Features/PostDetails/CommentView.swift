import Foundation
import SwiftUI

struct CommentView: View {
    
    @ObservedObject var comment: CommentModel
    let width: CGFloat
    let didTapOnURL: ((URL) -> Void)?
    init(
        comment: CommentModel,
        width: CGFloat,
        didTapOnURL: ((URL) -> Void)?
    ) {
        self.comment = comment
        self.width = width
        self.didTapOnURL = didTapOnURL
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PostUserView(viewModel: .init(comment: comment.comment), isCollapsed: comment.isCollapsed)
                .padding(.bottom, 14)
                .contentShape(Rectangle())
                .onLongPressGesture {
                    withAnimation {
                        comment.isCollapsed.toggle()
                    }
                }
            
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
                        width: width - Layout.levelIndent,
                        didTapOnURL: didTapOnURL
                    )
                    .padding(.leading, Layout.levelIndent)
                }
            }
            .showIf(!comment.isCollapsed)
        }
        .padding(.vertical, 8)
    }
}

private extension CommentView {
    struct Layout {
        static let levelIndent: CGFloat = 20
    }
}
