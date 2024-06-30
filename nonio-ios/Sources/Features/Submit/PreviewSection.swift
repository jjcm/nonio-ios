import SwiftUI

struct PreviewSection: View {

    private var post: Post!

    var body: some View {
        VStack {
            Text("Post title")

            PostRowView(
                viewModel: .init(post: post),
                votes: [],
                didTapUserProfileAction: {
                }, 
                didTapTag: { _ in },
                didTapPostLink: { _ in }
            )
        }
    }
}

#Preview {
    PreviewSection()
}
