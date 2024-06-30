import SwiftUI
import Kingfisher

struct PostRowView: View {
    let viewModel: PostViewModel
    let votes: [Vote]
    let didTapUserProfileAction: (() -> Void)
    let didTapTag: ((PostTag) -> Void)
    let didTapPostLink: ((Post) -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            headerView
            imageView
            linkView
            userView
            tagsView
        }
        .padding(.vertical, 10)
        .background(UIColor.systemBackground.color)
    }
    
    var headerView: some View {
        Text(viewModel.title)
            .font(.headline)
            .multilineTextAlignment(.leading)
            .lineLimit(1)
            .padding(.horizontal, 16)
    }
    
    var imageView: some View {
        KFImage(viewModel.imageURL)
            .resizable()
            .scaledToFill()
            .frame(width: viewModel.imageSize.width)
            .frame(height: viewModel.imageSize.height, alignment: .center)
            .clipped()
            .showIf(viewModel.shouldShowImage)
            .padding(.vertical, 10)
    }
    
    var linkView: some View {
        LinkView(urlString: viewModel.linkString) {
            didTapPostLink?(viewModel.post)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .showIf(viewModel.shouldShowLink)
    }
    
    var userView: some View {
        PostUserView(
            viewModel: .init(post: viewModel.post),
            commentVotesViewModel: .init(postURL: viewModel.post.url),
            didTapUserProfileAction: {
                didTapUserProfileAction()
            }
        )
        .padding(.horizontal, 16)
    }
    
    var tagsView: some View {
        HorizontalTagsScrollView(
            post: viewModel.post.url,
            tags: viewModel.post.tags,
            votes: votes,
            style: .init(height: 24, textColor: .secondary),
            onTap: { tag in
                didTapTag(tag)
            }
        )
        .padding(.horizontal, 16)
        .showIf(viewModel.shouldShowTags)
    }
}

#Preview {
    PostRowView(
        viewModel: .init(post: Post(
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
        )),
        votes: [],
        didTapUserProfileAction: {}, 
        didTapTag: { _ in },
        didTapPostLink: nil
    )
    .fixedSize()
    .environmentObject(AppSettings())
}
