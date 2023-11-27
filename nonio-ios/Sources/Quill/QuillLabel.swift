import SwiftUI
import UIKit

struct QuillLabel: UIViewRepresentable {
    let content: AttributedString
    let width: CGFloat

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let label  = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor),
            label.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        label.attributedText = NSAttributedString(content)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let label = uiView.subviews.first as? UILabel else { return }
        label.attributedText = NSAttributedString(content)
    }
}
