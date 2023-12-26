import SwiftUI

struct QuillContentView: View {
    let contents: [QuillViewRenderObject]
    let contentWidth: CGFloat
    let didTapOnURL: ((URL) -> Void)?
    init(
        contents: [QuillViewRenderObject],
        contentWidth: CGFloat,
        didTapOnURL: ((URL) -> Void)?
    ) {
        self.contents = contents
        self.contentWidth = contentWidth
        self.didTapOnURL = didTapOnURL
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
                            width: UIScreen.main.bounds.width, 
                            didTapOnURL: didTapOnURL
                        )
                        .frame(height: object.calculateContentHeight(containerWidth: width))
                        .frame(width: contentWidth)
                    }
                }
            }
        }
    }
    
    private var quoteBlock: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.4))
            .frame(maxHeight: .infinity)
            .frame(width: 6)
            .padding(.trailing, 12)
    }
}

extension QuillContentView {
    struct Layout {
        static let blockquoteLeadingMargin: CGFloat = 60
    }
    
    func getTextWidth(object: QuillViewRenderObject) -> CGFloat {
        let quoteLeading = object.isQuote ? Layout.blockquoteLeadingMargin : 0
        return contentWidth - quoteLeading
    }
}
