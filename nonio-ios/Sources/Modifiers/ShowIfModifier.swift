import SwiftUI

struct ShowIfModifier: ViewModifier {
    var show: Bool
    func body(content: Content) -> some View {
        if show {
            content
        } else {
            EmptyView()
        }
    }
}

extension View {
    func showIf(_ condition: Bool) -> some View {
        self.modifier(ShowIfModifier(show: condition))
    }
}
