import UIKit

struct QuillViewRenderObject: Identifiable {
    let id: String = UUID().uuidString
    let content: AttributedString
    let isQuote: Bool
    
    func calculateContentHeight(containerWidth: CGFloat) -> CGFloat {
        let boundingRect = NSAttributedString(content).boundingRect(
            with: .init(width: containerWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let scale = 1.0 / UIScreen.main.scale
        return scale * ceil(boundingRect.height/scale)
    }
}
