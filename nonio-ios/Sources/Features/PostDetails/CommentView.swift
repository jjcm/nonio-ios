import Foundation
import SwiftUI

struct CommentView: View {
    
    let comment: CommentModel
    init(comment: CommentModel) {
        self.comment = comment
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            QuillContentView(contents: comment.toQuillRenderObject(comment: comment.comment))
            
            ForEach(comment.children) { childComment in
                QuillContentView(contents: comment.toQuillRenderObject(comment: childComment))
                    .padding(.leading, 20) // Indent child comments
            }
        }
        .padding(.vertical, 4)
    }
}
