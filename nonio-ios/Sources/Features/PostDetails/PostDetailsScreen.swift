import SwiftUI
import Kingfisher


struct PostDetailsScreen: View {
    @ObservedObject var viewModel: PostDetailsViewModel
    @State private var openURLViewModel = ShowInAppBrowserViewModel()
    
    var body: some View {
        VStack {
            if viewModel.loading {
                ProgressView()
            } else {
                content
            }
        }
        .onLoad {
            viewModel.onLoad()
        }
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    headerView
                    if let type = viewModel.post.type {
                        mediaView(type: type)
                    }
                    linkView
                    userView
                    postContent
                    
                    Divider()
                        .frame(height: 1)
                        .background(UIColor.separator.color)
                    
                    tagsView
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
        PostUserView(viewModel: .init(post: viewModel.post))
            .padding(.top, 10)
            .padding(.horizontal, 16)
    }
    
    var tagsView: some View {
        HorizontalTagsScrollView(tags: viewModel.post.tags)
            .showIf(viewModel.shouldShowTags)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
    }
    
    var commentsView: some View {
        VStack {
            ForEach(viewModel.commentViewModels) { comment in
                CommentView(
                    comment: comment,
                    width: UIScreen.main.bounds.width - 2 * 16,
                    didTapOnURL: openURLViewModel.handleURL(_:)
                )
                .padding(.horizontal, 16)
            }
        }
    }
}
