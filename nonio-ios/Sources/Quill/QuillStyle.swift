import UIKit

protocol QuillContentStyle {
    var fontSize: CGFloat { get }
    var header1FontSize: CGFloat { get }
    var header2FontSize: CGFloat { get }
    var lineHeightMultiple: CGFloat { get }
    var underlineStyle: NSUnderlineStyle { get }
    var textColor: UIColor? { get }
    var backgroundColor: UIColor { get }
    var linkColor: UIColor { get }
    var bulletPointSymbol: String { get }
    var orderedListNumberFormat: (Int) -> String { get }
    var indentSizeFromIndentLevel: (Int) -> CGFloat { get }
    var orderedListNumberFormatter: (Int) -> String { get }
}


struct DefaultQuillStyle: QuillContentStyle {
    var fontSize: CGFloat { 14 }
    var header1FontSize: CGFloat { 24 }
    var header2FontSize: CGFloat { 20 }
    var lineHeightMultiple: CGFloat { 1.2 }
    var underlineStyle: NSUnderlineStyle { .single }
    var textColor: UIColor? = .label
    var backgroundColor: UIColor { .systemBackground }
    var linkColor: UIColor { .systemBlue }
    var bulletPointSymbol: String { "\u{2022}" }
    var orderedListNumberFormat: (Int) -> String { { "\($0)." } }
    var indentSizeFromIndentLevel: (Int) -> CGFloat { { CGFloat($0) * 2.0 * fontSize } }
    var orderedListNumberFormatter: (Int) -> String { { "\($0) "} }
}
