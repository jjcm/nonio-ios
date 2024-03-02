import SwiftUI
import Kingfisher

struct PostDetailsScreen: View {
    @EnvironmentObject var settings: AppSettings
    @ObservedObject var viewModel: PostDetailsViewModel
    @State private var openURLViewModel = ShowInAppBrowserViewModel()
    @State private var selectedUser: String?
    @State private var showCommentEditor = false
    @State private var showEditorWithComment: Comment?
    @State private var highlightAnimationEnded: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.loading {
                    ProgressView()
                } else {
                    content
                }
            }
            .navigationDestination(for: $selectedUser) { user in
                UserScreen(param: .user(user))
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.post?.detailsTitle ?? "")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onLoad {
            viewModel.onLoad()
            viewModel.commentVotesViewModel.fetchCommentVotes(hasLoggedIn: settings.hasLoggedIn)
        }
        .sheet(isPresented: $showCommentEditor) {
            commentEditorView(nil)
        }
        .sheet(item: $showEditorWithComment) { comment in
            commentEditorView(comment)
        }
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            ScrollViewReader { scrollProxy in
                List {
                    if let post = viewModel.post {
                        mediaView(post: post)
                            .plainListItem()
                        linkView(post: post)
                            .plainListItem()
                        userView(post: post)
                            .plainListItem()
                        postContent
                            .plainListItem()
                        tagsView(post: post)
                            .plainListItem()

                        Divider()
                            .frame(height: 1)
                            .background(UIColor.separator.color)

                        commentButton
                            .plainListItem()
                        commentsView
                            .plainListItem()
                    }
                }
                .listStyle(.plain)
                .onChange(of: viewModel.scrollToComment) { id in
                    withAnimation {
                        scrollProxy.scrollTo(id)
                    }
                }
            }
        }
        .openURL(viewModel: openURLViewModel)
        .padding(.vertical, 10)
        .background(UIColor.systemBackground.color)
    }
    
    var postContent: some View {
        QuillContentView(
            contents: viewModel.postContent,
            contentWidth: UIScreen.main.bounds.width - 16 * 2,
            didTapOnURL: openURLViewModel.handleURL(_:)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
    
    var headerView: some View {
        Text(viewModel.title)
            .font(.headline)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func mediaView(post: Post) -> some View {
        switch post.type {
        case .image:
            if let imageURL = post.imageURL {
                KFImage(imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: post.mediaSize.width)
                    .frame(height: post.mediaSize.height, alignment: .center)
                    .clipped()
                    .showIf(post.shouldShowImage)
            }
        case .video:
            if let videoURL = post.videoURL {
                PostVideoPlayerView(url: videoURL)
                    .frame(width: post.mediaSize.width)
                    .frame(height: post.mediaSize.height)
            }
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func linkView(post: Post) -> some View {
        LinkView(urlString: post.linkString) {
            guard let url = post.link else { return }
            openURLViewModel.handleURL(url)
        }
        .padding(.horizontal, 16)
        .showIf(post.shouldShowLink)
    }
    
    @ViewBuilder
    func userView(post: Post) -> some View {
        PostUserView(
            viewModel: .init(post: post),
            commentVotesViewModel: CommentVotesViewModel(postURL: post.url),
            didTapUserProfileAction: {
                didTapUserProfile(user: post.user)
            }
        )
        .padding(.top, 10)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func tagsView(post: Post) -> some View {
        HorizontalTagsScrollView(
            post: post.url,
            tags: post.tags,
            votes: viewModel.votes,
            style: .init(height: 28, textColor: .blue)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .showIf(post.shouldShowTags)
    }
    
    var commentsView: some View {
        ForEach(viewModel.commentViewModels) { comment in
            CommentView(
                comment: comment,
                showUpvoteCount: true,
                width: UIScreen.main.bounds.width - 2 * 16,
                commentVotesViewModel: viewModel.commentVotesViewModel,
                showHighlightedAnimation: !highlightAnimationEnded && viewModel.scrollToComment == comment.id,
                didTapOnURL: openURLViewModel.handleURL(_:),
                didTapUserProfileAction: { user in
                    didTapUserProfile(user: user)
                },
                animationEnded: {
                    highlightAnimationEnded = true
                }
            )
            .id(comment.id)
            .environmentObject(viewModel.commentVotesViewModel)
            .swipeActions {
                Button {
                    replyComment(comment)
                } label: {
                    Icon(image: R.image.replyDown.image, size: .medium)
                }
                .tint(.blue)
            }
        }
    }
    
    var commentButton: some View {
        CommentButton(action: {
            showCommentEditor = true
        })
    }
    
    @ViewBuilder
    func commentEditorView(_ comment: Comment?) -> some View {
        CommentEditorScreen(postURL: viewModel.postURL, comment: comment) { comment in
            showCommentEditor = false
            showEditorWithComment = nil
            viewModel.onLoad()
        } didCancel: {
            showCommentEditor = false
            showEditorWithComment = nil
        }
    }
}

private extension PostDetailsScreen {
    func didTapUserProfile(user: String) {
        selectedUser = user
    }
    
    func replyComment(_ comment: CommentModel) {
        showEditorWithComment = comment.comment
    }
}
