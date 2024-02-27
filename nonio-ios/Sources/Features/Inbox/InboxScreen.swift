import SwiftUI

struct InboxScreen: View {
    @StateObject var viewModel: InboxViewModel
    @State private var selectedUser: String?
    @State private var selectedPost: Post?

    var body: some View {
        ZStack {
            content

            if viewModel.loading {
                ProgressView()
            }
        }
    }

    var content: some View {
        NavigationStack {
            List(viewModel.models, id: \.self) { model in
                row(model: model)
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .background(UIColor.secondarySystemBackground.color)
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                viewModel.fetch()
            }
            .navigationDestination(for: $selectedUser) { user in
                UserScreen(param: .user(user))
            }
            .navigationDestination(for: $selectedPost) { post in
                PostDetailsScreen(
                    viewModel: .init(
                        post: post,
                        votes: []
                    )
                )
            }
        }
        .onLoad {
            viewModel.fetch()
        }
    }

    @ViewBuilder
    func row(model: InboxNotification) -> some View {
        VStack {
            PostUserView(
                viewModel: model.userViewModel,
                commentVotesViewModel: model.commentVotesViewModel,
                didTapUserProfileAction: {
                    selectedUser = model.user
                }
            )
            .padding(.vertical, 10)

            QuillContentView(
                contents: viewModel.toQuillRenderObject(content: model.content),
                contentWidth: UIScreen.main.bounds.width - Layout.horizontalPadding * 2) { _ in
                    // open link if needed
                }
                .padding(.bottom, 8)

            postLink(model: model)
                .padding(.bottom, 10)
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .background(UIColor.systemBackground.color)
        .plainListItem()
    }

    @ViewBuilder
    func postLink(model: InboxNotification) -> some View {
        Button {
            selectedPost = Post.make(from: model)
        } label: {
            HStack {
                // todo: image
                Image("")
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Text(model.post_title)
                    .foregroundColor(UIColor.label.color)
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                Icon(image: R.image.chevronRight.image, size: .small)
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .padding()
            .frame(height: 32)
            .background(UIColor.secondarySystemBackground.color)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

private extension InboxScreen {
    struct Layout {
        static let horizontalPadding: CGFloat = 16
    }
}

#Preview {
    InboxScreen(viewModel: .init())
}
