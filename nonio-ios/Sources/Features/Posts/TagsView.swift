import SwiftUI

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
    TagsView(
        tags: [
            .init(
                postID: 1,
                tag: "Tag1",
                tagID: 1,
                score: 1),
            .init(
                postID: 2,
                tag: "TagTag2",
                tagID: 2,
                score: 1),
        ]
    )
    .padding()
}
