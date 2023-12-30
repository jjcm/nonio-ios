import SwiftUI
import Kingfisher

struct PostRowView: View {
    let viewModel: PostViewModel
    let votes: [Vote]
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
        PostUserView(viewModel: .init(post: viewModel.post, showUpvoteCount: true), commentVotesViewModel: .init(post: viewModel.post))
            .padding(.horizontal, 16)
    }
    
    var tagsView: some View {
        HorizontalTagsScrollView(
            post: viewModel.post.url,
            tags: viewModel.post.tags,
            votes: votes,
            style: .init(height: 24, textColor: .secondary)
        )
        .padding(.horizontal, 16)
        .showIf(viewModel.shouldShowTags)
    }
}

struct TagsView: View {
    var tags: [PostTag]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.tag) { tag in
                    Text("#\(tag.tag)")
                        .padding(5)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(5)
                }
            }
        }
    }
}
