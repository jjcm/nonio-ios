import SwiftUI

struct LinkView: View {
    var urlString: String
    var onTap: () -> Void
    @State var openURLViewModel = ShowInAppBrowserViewModel()

    var body: some View {
        Button {
            guard let url = URL(string: urlString) else { return }
            openURLViewModel.handleURL(url)
        } label: {
            PlainLinkView(urlString: urlString)
        }
        .openURL(viewModel: openURLViewModel)
    }
}

#Preview {
    LinkView(urlString: "https://www.youtube.com/watch?v=yzC4hFK5P3g") {
        
    }
}
