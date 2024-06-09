import SwiftUI
import Kingfisher

struct PostPreviewView: View {

    let title: String
    let description: String
    let link: String?
    let image: URL?
    let user: String
    let tags: [String]

    private var tagModels: [PostTag] {
        tags.enumerated().map { .init(postID: $0.offset, tag: $0.element, tagID: $0.offset, score: 0)}
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerView
                .padding(.leading, 16)
            if let image {
                imageView(image: image)
            }

            Section {
                if let link {
                    linkView(link: link)
                }

                if description.isNotEmpty {
                    descriptionView
                }
                
                userView
                tagsView
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(UIColor.systemBackground.color)
    }

    var headerView: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .showIf(title.isNotEmpty)
    }

    @ViewBuilder
    func imageView(image: URL) -> some View {
        KFImage(image)
            .placeholder {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(.blue)

                    Icon(image: R.image.image_add.image, size: .medium)
                        .foregroundStyle(.white)
                }
            }
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .clipped()
    }

    @ViewBuilder
    func linkView(link: String) -> some View {
        PlainLinkView(urlString: link)
            .showIf(link.isNotEmpty)
    }

    var descriptionView: some View {
        Text(description)
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var userView: some View {
        HStack {
            HStack(spacing: 8) {
                KFImage(ImageURLGenerator.userAvatarURL(user: user))
                    .placeholder {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.primary)
                    }
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())

                HStack {
                    Text(user)
                        .font(.system(size: 12))
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Text("1 vote")

                HStack(spacing: 4) {
                    Icon(image: R.image.clock.image, size: .small)
                    Text("just now")
                }

                HStack(spacing: 4) {
                    Icon(image: R.image.comment.image, size: .small)
                    Text("0")
                }            }
            .foregroundColor(UIColor.darkGray.color)
            .font(.subheadline)
            .cornerRadius(10)
        }
    }

    var tagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(tagModels, id: \.tagID) { tag in
                    HStack {
                        HStack {
                            Icon(image: R.image.upvote.image, size: .small)
                            Text("1")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }

                        Text(tag.tag)
                            .frame(maxHeight: .infinity)
                            .padding(.horizontal, 8)
                            .cornerRadius(2)
                            .background(PostTagView.Style.bgColor)
                    }
                    .background(PostTagView.Style.tagBGColor)
                    .cornerRadius(8)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .frame(height: 24)
        .showIf(!tags.isEmpty)
    }
}

#Preview {
    PostPreviewView(
        title: "Post title",
        description: "An optional description for the post. An optional description for the post",
        link: "https://en.wikipedia.org/wiki/Wikipedia",
        image: nil,
        user: "tom",
        tags: ["one", "two"]
    )
}
