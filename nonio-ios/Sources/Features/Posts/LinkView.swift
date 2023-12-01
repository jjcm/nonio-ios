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
            HStack {
                Icon(image: R.image.link.image, size: .big)
                
                Text(urlString)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Icon(image: R.image.chevronRight.image, size: .big)
            }
            .padding(8)
            .background(UIColor.systemGray6.color)
            .cornerRadius(10)
            .frame(height: 32)
        }
        .openURL(viewModel: openURLViewModel)
    }
}

#Preview {
    LinkView(urlString: "https://www.youtube.com/watch?v=yzC4hFK5P3g") {
        
    }
}
