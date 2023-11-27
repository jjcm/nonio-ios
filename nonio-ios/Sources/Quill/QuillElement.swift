import Foundation
import SwiftUI

struct QuillJSContent: Decodable {
    var ops: [QuillOperation]
}

struct QuillOperation: Decodable {
    var insert: String
    var attributes: QuillAttributes?
}

struct QuillAttributes: Decodable {
    var bold: Bool?
    var italic: Bool?
    var header: Int?
    var blockquote: Bool?
    var link: String?
    var list: ListType?
    var attributes: Bool?
    var strike: Bool?
    var underline: Bool?
    var indent: Int?
    var align: String?
}


struct QuillElement {
    var insert: String
    var attributes: QuillAttributes?
}

struct LinkAttritubes: Hashable {
    let text: String
    let url: URL
}

enum ListType: String, Decodable {
    case ordered, bullet
}


extension QuillOperation {
    var isBlock: Bool {
        insert == "\n" && attributes != nil
    }
}




