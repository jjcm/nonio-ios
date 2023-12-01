import SwiftUI

struct OnLoadModifier: ViewModifier {
    @State private var viewDidLoad = false
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad == false {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}

extension View {
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(OnLoadModifier(action: action))
    }
}
