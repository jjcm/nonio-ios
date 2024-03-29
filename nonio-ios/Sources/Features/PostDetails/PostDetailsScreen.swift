import SwiftUI
import Kingfisher


struct PostDetailsScreen: View {
    @EnvironmentObject var settings: AppSettings
    @ObservedObject var viewModel: PostDetailsViewModel
    @State private var openURLViewModel = ShowInAppBrowserViewModel()
    @State private var selectedUser: String?
    @State private var showCommentEditor = false
    @State private var showEditorWithComment: Comment?

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
                    Text(viewModel.title)
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
            commentView(nil)
        }
        .sheet(item: $showEditorWithComment) { comment in
            commentView(comment)
        }
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    if let type = viewModel.post.type {
                        mediaView(type: type)
                    }
                    linkView
                    userView
                    postContent
                    tagsView
                    
                    Divider()
                        .frame(height: 1)
                        .background(UIColor.separator.color)
                    
                    commentButton
                    commentsView
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
    func mediaView(type: Post.ContentType) -> some View {
        switch type {
        case .image:
            if let imageURL = viewModel.imageURL {
                KFImage(imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: viewModel.mediaSize.width)
                    .frame(height: viewModel.mediaSize.height, alignment: .center)
                    .clipped()
                    .showIf(viewModel.shouldShowImage)
            }
        case .video:
            if let videoURL = viewModel.videoURL {
                PostVideoPlayerView(url: videoURL)
                    .frame(width: viewModel.mediaSize.width)
                    .frame(height: viewModel.mediaSize.height)
            }
        default:
            EmptyView()
        }
    }
    
    var linkView: some View {
        LinkView(urlString: viewModel.linkString) {
            guard let url = viewModel.post.link else { return }
            openURLViewModel.handleURL(url)
        }
        .padding(.horizontal, 16)
        .showIf(viewModel.shouldShowLink)
    }
    
    var userView: some View {
        PostUserView(
            viewModel: .init(
                post: viewModel.post,
                showUpvoteCount: true
            ),
            commentVotesViewModel: viewModel.commentVotesViewModel,
            didTapUserProfileAction: {
                didTapUserProfile(user: viewModel.post.user)
            }
        )
        .padding(.top, 10)
        .padding(.horizontal, 16)
        .environmentObject(viewModel.commentVotesViewModel)
    }
    
    var tagsView: some View {
        HorizontalTagsScrollView(
            post: viewModel.post.url,
            tags: viewModel.post.tags,
            votes: viewModel.votes,
            style: .init(height: 28, textColor: .blue)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
        .showIf(viewModel.shouldShowTags)
    }
    
    var commentsView: some View {
        VStack {
            ForEach(viewModel.commentViewModels) { comment in
                CommentView(
                    comment: comment,
                    showUpvoteCount: true,
                    width: UIScreen.main.bounds.width - 2 * 16,
                    commentVotesViewModel: viewModel.commentVotesViewModel,
                    didTapOnURL: openURLViewModel.handleURL(_:),
                    didTapUserProfileAction: { user in
                        didTapUserProfile(user: user)
                    },
                    replyAction: { comment in
                        replyComment(comment)
                    }
                )
                .padding(.leading, 16)
                .environmentObject(viewModel.commentVotesViewModel)
            }
        }
    }
    
    var commentButton: some View {
        CommentButton(action: {
            showCommentEditor = true
        })
    }
    
    @ViewBuilder
    func commentView(_ comment: Comment?) -> some View {
        CommentEditorScreen(post: viewModel.post, comment: comment) { comment in
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
