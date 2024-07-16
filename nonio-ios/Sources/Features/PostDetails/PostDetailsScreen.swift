import SwiftUI
import Kingfisher

struct PostDetailsScreen: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: PostDetailsViewModel
    @State private var openURLViewModel = ShowInAppBrowserViewModel()
    @State private var selectedUser: String?
    @State private var showCommentEditor = false
    @State private var showEditorWithComment: Comment?
    @State private var commentAnimationHasShown: Bool = false
    @State private var animationEnded: Bool = false
    @State private var showTagsSearchView = false
    @State private var presentFullScreenVideoPlayer: Bool = false

    let onTap: ((PostTag) -> Void)
    init(
        viewModel: PostDetailsViewModel,
        openURLViewModel: ShowInAppBrowserViewModel = ShowInAppBrowserViewModel(),
        selectedUser: String? = nil,
        showCommentEditor: Bool = false,
        onTap: @escaping ((PostTag)) -> Void = { _ in }
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.openURLViewModel = openURLViewModel
        self.selectedUser = selectedUser
        self.showCommentEditor = showCommentEditor
        self.onTap = onTap
    }

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
                .onChange(of: viewModel.scrollToComment) { _, id in
                    guard let id else { return }
                    withAnimation {
                        scrollProxy.scrollTo(id)
                    }
                }
                .sheet(isPresented: $showTagsSearchView, content: {
                    SearchScreen(showCreateNewTag: true) { tag in
                        showTagsSearchView = false
                        if let tag, let post = viewModel.post {
                            viewModel.addTag(tag.tag, postID: post.ID)
                        }
                    } onCancel: {
                        showTagsSearchView = false
                    }
                })
                .landscapeFullScreenCover(isPresented: $presentFullScreenVideoPlayer) {
                    VideoPlayerView(url: viewModel.post?.videoURL) {
                       presentFullScreenVideoPlayer = false
                    }
                    .ignoresSafeArea()
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
        .showIf(!viewModel.postContent.isEmpty)
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
                VideoPlayerView(url: videoURL)
                    .frame(width: post.mediaSize.width)
                    .frame(height: post.mediaSize.height)
                    .overlay(alignment: .topLeading) {
                        Button {
                            presentFullScreenVideoPlayer = true
                        } label: {
                            Icon(image: Image(systemName: "arrow.up.left.and.arrow.down.right"), size: .small)
                                .foregroundColor(.white)
                                .padding(.trailing)
                        }
                        .padding()
                    }
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
            viewModel: .init(tags: post.tags),
            style: .default
        ) { tag in
            onTap(tag)
            dismiss()
        } onAdd: {
            showTagsSearchView = true
        }
        .environmentObject(PostTagViewModel(tags: viewModel.tags))
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
    
    var commentsView: some View {
        ForEach(viewModel.commentViewModels) { comment in
            let showAnimation = !commentAnimationHasShown && !animationEnded && viewModel.scrollToComment == comment.id
            CommentView(
                comment: comment,
                showUpvoteCount: true,
                width: UIScreen.main.bounds.width - 2 * 16,
                commentVotesViewModel: viewModel.commentVotesViewModel,
                didTapOnURL: openURLViewModel.handleURL(_:),
                didTapUserProfileAction: { user in
                    didTapUserProfile(user: user)
                }
            )
            .background(showAnimation ? UIColor.secondarySystemBackground.color : .clear)
            .onAppear {
                let duration = 1.2
                if showAnimation {
                    withAnimation(.linear(duration: duration)) {
                        commentAnimationHasShown = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        commentAnimationHasShown = false
                        animationEnded = true
                    }
                }
            }
            .animation(.easeInOut, value: showAnimation)
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

#Preview {
    PostDetailsScreen(
        viewModel: .init(
            post: Post(
                id: 1,
                title: "test image",
                user: "user",
                time: 1717334831000,
                url: "test-image-2",
                link: nil,
                type: .image,
                content: "{\"ops\":[{\"insert\":\"test description\\n\"}]}",
                score: 10,
                commentCount: 20,
                tags: [.init(postID: 1, tag: "Tag", tagID: 100, score: 1)]
            ),
            votes: []
        ),
        onTap: { _ in }
    )
    .environmentObject(AppSettings())
}
