import SwiftUI
import Foundation

struct QuillParser {
    let decoder = JSONDecoder()
    let style: QuillContentStyle
    init(style: QuillContentStyle = DefaultQuillStyle()) {
        self.style = style
    }
   
    func parseQuillJS(json: String) -> [QuillViewRenderObject] {
        guard let data = json.data(using: .utf8),
              let content = try? decoder.decode(QuillJSContent.self, from: data) else {
            return []
        }
        
        var result = [QuillViewRenderObject]()
        var line = [QuillElement]()
        var currentIndentMap = [Int: Int]()
        
        for op in content.ops {
            let texts = op.insert.components(separatedBy: "\n")
            let isBlock = op.isBlock
            
            if isBlock {
                line.append(.init(insert: "", attributes: op.attributes))
                var blockquote = false
                result.append(stringFromLines(line, currentIndentMap: &currentIndentMap, blockquote: &blockquote))
                line = []
            } else {
                for (index, text) in texts.enumerated() {
                    line.append(.init(insert: text, attributes: op.attributes))
                    if op.insert.contains("\n") && index < texts.count - 1 {
                        var blockquote = false
                        result.append(stringFromLines(line, currentIndentMap: &currentIndentMap, blockquote: &blockquote))
                        line = []
                    }
                }
            }
        }

        return result
    }
    
    private func stringFromLines(
        _ lines: [QuillElement],
        currentIndentMap: inout [Int: Int],
        blockquote: inout Bool
    ) -> QuillViewRenderObject {
        var lines = lines
        var result = AttributedString()
                
        // block
        var headerLevel = 0
        var indentLevel = 0
        var textIndent: CGFloat = 0
        if let blockAttr = lines.last?.attributes {
            if let header = blockAttr.header {
                headerLevel = header
            }
            
            if let indent = blockAttr.indent {
                indentLevel = indent
                if indent > 0 {
                    textIndent = style.indentSizeFromIndentLevel(indent)
                }
            }
                    
            switch blockAttr.list {
            case .ordered:
                let number = orderListNumber(&currentIndentMap, indent: indentLevel)
                let numberText = style.orderedListNumberFormatter(number)
                lines.insert(.init(insert: "\(numberText).  "), at: 0)
            case .bullet:
                lines.insert(.init(insert: "  \(style.bulletPointSymbol) "), at: 0)
            default:
                currentIndentMap.removeAll()
            }
            
            if blockAttr.blockquote == true {
                blockquote = true
            }
        }
        
        // inline        
        for line in lines {
            var attText = AttributedString(line.insert)
            var attContainer = AttributeContainer()
            let attributes = line.attributes
            var fontSize = style.fontSize
            var fontTraits = UIFontDescriptor.SymbolicTraits()
            
            if attributes?.bold == true {
                fontTraits.insert(.traitBold)
            }
            if attributes?.italic == true {
                fontTraits.insert(.traitItalic)
            }
            if attributes?.underline == true {
                attContainer.underlineStyle = .single
            }
            if attributes?.strike == true {
                attContainer.strikethroughStyle = .single
            }
            if let link = attributes?.link {
                attContainer.link = .init(string: link)
            }
            
            if headerLevel > 0 {
                switch headerLevel {
                case 1:
                    fontSize = style.header1FontSize
                    attText.insert(AttributedString("\n"), at: attText.startIndex)
                    fontTraits.insert(.traitBold)
                case 2:
                    fontSize = style.header2FontSize
                    attText.insert(AttributedString("\n"), at: attText.startIndex)
                    fontTraits.insert(.traitBold)
                default:
                    break
                }
            }
             
            var font = UIFont.systemFont(ofSize: style.fontSize)
            if !fontTraits.isEmpty,
               let fontDesc = font.fontDescriptor.withSymbolicTraits(fontTraits) {
                font = UIFont(descriptor: fontDesc, size: fontSize)
            }
            
            if fontSize > 0 {
                font = font.withSize(fontSize)
            }
          
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left
            paragraphStyle.firstLineHeadIndent = textIndent
            paragraphStyle.headIndent = textIndent
            paragraphStyle.minimumLineHeight = font.lineHeight * style.lineHeightMultiple
                                   
            attContainer.font = font
            attText.setAttributes(attContainer)
            attText.mergeAttributes(.init([.paragraphStyle: paragraphStyle]))
            result.append(attText)
        }
        return .init(content: result, isQuote: blockquote)
    }
    
    private func orderListNumber(_ currentIndentMap: inout [Int: Int], indent: Int) -> Int {
        let result = currentIndentMap[indent, default: 1]
        currentIndentMap[indent] = result + 1
        return result
    }
}
