import SwiftUI

struct LandscapeFullScreenCover<CoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder let coverContent: () -> CoverContent
    @State private var supportedOrientations: UIInterfaceOrientationMask = .portrait

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                coverContent()
            }
            .onChange(of: isPresented, perform: { supportedOrientations = $0 ? .landscape : .portrait })
            .supportedOrientations(supportedOrientations)
    }
}

extension View {
    func landscapeFullScreenCover(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> some View) -> some View {
        modifier(LandscapeFullScreenCover(isPresented: isPresented, coverContent: content))
    }
}
