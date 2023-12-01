import SwiftUI
import Kingfisher

struct PostRowView: View {
    let viewModel: PostViewModel
    var didTapPostLink: ((Post) -> Void)?
    
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
        PostUserView(viewModel: .init(post: viewModel.post))
            .padding(.horizontal, 16)
    }
    
    var tagsView: some View {
        HorizontalTagsScrollView(tags: viewModel.post.tags)
            .showIf(viewModel.shouldShowTags)
            .padding(.horizontal, 16)
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

#Preview {
    PostRowView(
        viewModel: .init(
            post:
                Post(
                    id: 2,
                    title: "test post",
                    user: "jjcm",
                    time: 1699151931000,
                    url: "avo-coffeeshop",
                    link: URL(string: "https://www.google.com"),
                    type: .image,
                    content: "",
                    score: 148,
                    commentCount: 21,
                    width: 100,
                    height: 100,
                    tags: [
                        .init(postID: 1, tag: "hahahahahah", tagID: 1, score: 5),
                        .init(postID: 1, tag: "hahahahahah", tagID: 2, score: 5),
                        .init(postID: 1, tag: "hahahahahah", tagID: 3, score: 5),
                        .init(postID: 1, tag: "hahahahahah", tagID: 1, score: 5),
                    ]
                )
        )
    )
}
