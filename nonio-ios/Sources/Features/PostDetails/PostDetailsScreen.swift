import SwiftUI
import Kingfisher

struct PostDetailsScreen: View {
    let viewModel: PostDetailsViewModel
    var didTapPostLink: ((Post) -> Void)?
    
    var body: some View {
        if viewModel.loading {
            ProgressView()
        } else {
            content
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
                    tagsView
                    commentsView
                }
            }
        }
        .onAppear {
            viewModel.onLoad()
        }
        .padding(.vertical, 10)
        .background(UIColor.systemBackground.color)
    }
    
    var postContent: some View {
        QuillContentView(contents: viewModel.postContent)
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
            didTapPostLink?(viewModel.post)
        }
        .padding(.horizontal, 16)
        .showIf(viewModel.shouldShowLink)
    }
    
    var userView: some View {
        PostUserView(post: viewModel.post)
            .padding(.horizontal, 16)
    }
    
    var tagsView: some View {
        HorizontalTagsScrollView(tags: viewModel.post.tags)
            .showIf(viewModel.shouldShowTags)
            .padding(.horizontal, 16)
    }
    
    var commentsView: some View {
        VStack {
            ForEach(viewModel.commentViewModels) { comment in
                CommentView(comment: comment)
            }
        }
    }
}


#Preview {
    PostDetailsScreen(viewModel: .init(post: Post(
        id: 2,
        title: "test post",
        user: "jjcm",
        time: 1699151931000,
        url: "salt",
        link: URL(string: "https://www.google.com"),
        type: .image,
        content: "{\"ops\":[{\"insert\":\"Header 1\"},{\"attributes\":{\"header\":1},\"insert\":\"\\n\"},{\"insert\":\"\\n\\nhello \"},{\"attributes\":{\"bold\":true},\"insert\":\"bold\"},{\"insert\":\" \"},{\"attributes\":{\"italic\":true},\"insert\":\"italic\"},{\"insert\":\"\\nHeader 2\"},{\"attributes\":{\"header\":2},\"insert\":\"\\n\"},{\"insert\":\"\\n\"},{\"attributes\":{\"italic\":true},\"insert\":\"this\"},{\"insert\":\" is a \"},{\"attributes\":{\"bold\":true},\"insert\":\"long long long long long long long long long long long long long long long long long long  quote, \"},{\"attributes\":{\"link\":\"google.com\"},\"insert\":\"google.com\"},{\"attributes\":{\"blockquote\":true},\"insert\":\"\\n\"},{\"insert\":\"\\n\\nThis is an ordered list\\n\"},{\"attributes\":{\"bold\":true},\"insert\":\"number\"},{\"insert\":\" 1\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"attributes\":{\"italic\":true},\"insert\":\"number\"},{\"insert\":\" 2\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"attributes\":{\"code\":true},\"insert\":\"number\"},{\"insert\":\" 3\"},{\"attributes\":{\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"3.1\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"3.2\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"3.3\"},{\"attributes\":{\"indent\":1,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"haha\"},{\"attributes\":{\"indent\":2,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"hehe\"},{\"attributes\":{\"indent\":2,\"list\":\"ordered\"},\"insert\":\"\\n\"},{\"insert\":\"\\nThis is a list\\nnumber 1\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"number 1.1\"},{\"attributes\":{\"indent\":1,\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"number 1.2\"},{\"attributes\":{\"indent\":1,\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"number 2\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"number 3\"},{\"attributes\":{\"list\":\"bullet\"},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]}",
        score: 148,
        commentCount: 21,
        width: 100,
        height: 100,
        tags: [.init(postID: 1, tag: "music-videos", tagID: 1, score: 5), .init(postID: 1, tag: "painting", tagID: 2, score: 5), .init(postID: 1, tag: "traditional", tagID: 3, score: 5), .init(postID: 4, tag: "football", tagID: 1, score: 5),]
    ),
                                       provider: .init()
    ))
}
