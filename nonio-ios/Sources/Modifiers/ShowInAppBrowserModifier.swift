import SwiftUI
import Combine

final class ShowInAppBrowserViewModel: ObservableObject {
    struct URLObject: Identifiable {
        var id: String {
            url.absoluteString
        }
        var url: URL
    }
    
    @Published var didTapURL: URLObject?
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func handleURL(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            alertMessage = "The URL (\(url.absoluteString)) is not supported."
            showAlert = true
            return
        }
        didTapURL = URLObject(url: url)
    }
}

struct ShowInAppBrowserModifier: ViewModifier {
    @ObservedObject var viewModel: ShowInAppBrowserViewModel
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $viewModel.didTapURL) { urlObject in
                SafariView(url: urlObject.url)
            }
            .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert, actions: {
                Button(action: {
                    
                }, label: {
                    Text("Ok")
                })
            })
    }
}

extension View {
    func openURL(
        viewModel: ShowInAppBrowserViewModel,
        ignoreError: Bool = false
    ) -> some View {
        self.modifier(ShowInAppBrowserModifier(viewModel: viewModel))
    }
}
