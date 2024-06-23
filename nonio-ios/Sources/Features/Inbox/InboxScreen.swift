import SwiftUI
import Kingfisher

struct InboxScreen: View {
    @StateObject var viewModel: InboxViewModel
    @State private var selectedUser: String?
    @State private var selectedNotification: InboxNotification?
    @EnvironmentObject var notificationDataTicker: NotificationUnreadTicker
    @State private var openURLViewModel = ShowInAppBrowserViewModel()

    init(
        viewModel: InboxViewModel,
        selectedUser: String? = nil,
        selectedNotification: InboxNotification? = nil,
        openURLViewModel: ShowInAppBrowserViewModel = ShowInAppBrowserViewModel()
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.selectedUser = selectedUser
        self.selectedNotification = selectedNotification
        self.openURLViewModel = openURLViewModel
    }

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
            .navigationDestination(for: $selectedNotification) { notification in
                return PostDetailsScreen(
                    viewModel: .init(
                        postURL: notification.post,
                        votes: [],
                        scrollToComment: notification.comment_id
                    )
                )
            }
            .openURL(viewModel: openURLViewModel)
        }
        .onLoad {
            viewModel.fetch()
        }
        .onChange(of: viewModel.unreadCountUpdated) { count in
            guard let count else { return }
            notificationDataTicker.updateCount(count)
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

            if !model.parent_content.isEmpty {
                parentContent(model.parent_content)
            }

            QuillContentView(
                contents: viewModel.toQuillRenderObject(model: model),
                contentWidth: UIScreen.main.bounds.width - Layout.horizontalPadding * 2,
                didTapOnURL: openURLViewModel.handleURL(_:)
            )
            .padding(.bottom, 8)

            postLink(model: model)
                .padding(.bottom, 10)
                .showIf(!model.post_title.isEmpty)
        }
        .padding(.horizontal, Layout.horizontalPadding)
        .background(UIColor.systemBackground.color)
        .plainListItem()
    }

    @ViewBuilder
    func postLink(model: InboxNotification) -> some View {
        Button {
            viewModel.markAsReadIfNeeded(notification: model)
            selectedNotification = model
        } label: {
            HStack {
                if let imageURL = model.postImageURL {
                    KFImage(imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48)
                        .clipped()
                }
                Text(model.post_title)
                    .foregroundColor(UIColor.label.color)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, model.postImageURL == nil ? 16 : 0)

                Spacer()

                Icon(image: R.image.chevronRight.image, size: .small)
                    .foregroundColor(UIColor.secondaryLabel.color)
                    .padding(.trailing, 16)
            }
            .frame(height: 32)
            .background(UIColor.secondarySystemBackground.color)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func parentContent(_ content: String) -> some View {
        HStack {
            Rectangle()
                .fill(UIColor.opaqueSeparator.color)
                .frame(width: 2)
                .frame(maxHeight: .infinity)

            QuillContentView(
                contents: viewModel.toParentContentQuillRenderObject(string: content),
                contentWidth: UIScreen.main.bounds.width - Layout.horizontalPadding * 2 - 10,
                didTapOnURL: openURLViewModel.handleURL(_:)
            )
        }
    }
}

private extension InboxScreen {
    struct Layout {
        static let horizontalPadding: CGFloat = 16
    }
}

#Preview {
    InboxScreen(
        viewModel: .init(
            models: [
                .init(
                    id: 1,
                    comment_id: 2,
                    date: 1717334831000,
                    post: "post",
                    post_title: "post title",
                    content: "{\"ops\":[{\"insert\":\"test comment\"},{\"attributes\":{\"blockquote\":true},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]}",
                    user: "user",
                    upvotes: 10,
                    downvotes: 1,
                    parent: -1,
                    edited: false,
                    read: false,
                    post_type: "text",
                    parent_content: "{\"ops\":[{\"insert\":\"test comment\"},{\"attributes\":{\"blockquote\":true},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]}"
                )
            ]
        )
    )
    .environmentObject(AppSettings())
    .environmentObject(NotificationUnreadTicker())
}
