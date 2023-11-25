import SwiftUI

struct PostDetailView: View {
    var contents: [QuillViewRenderObject]
    var comments: [QuillElement]
    let parser = QuillParser()
    
    let post: Post
    init(post: Post) {
        self.post = post
        self.contents = parser.parseQuillJS(json: post.content)
        self.comments = []
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(contents) { object in
                    let width = getTextWidth(object: object)
                    
                    HStack(alignment: .center) {
                        quoteBlock
                            .showIf(object.isQuote)

                        QuillLabel(
                            content: object.content,
                            width: UIScreen.main.bounds.width
                        )
                        .frame(height: object.calculateContentHeight(containerWidth: width))
                        .frame(width: width)
                    }
                }
            }
        }
        .padding(.horizontal, Layout.contentHorizontalInset)
    }
    
    private var quoteBlock: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.4))
            .frame(maxHeight: .infinity)
            .frame(width: 6)
            .padding(.trailing, 12)
    }
}

extension PostDetailView {
    struct Layout {
        static let contentHorizontalInset: CGFloat = 16
        static let contentWidth = UIScreen.main.bounds.width - 2 * contentHorizontalInset
        static let blockquoteLeadingMargin: CGFloat = 60
    }
    
    func getTextWidth(object: QuillViewRenderObject) -> CGFloat {
        let quoteLeading = object.isQuote ? Layout.blockquoteLeadingMargin : 0
        return Layout.contentWidth - quoteLeading
    }
}
