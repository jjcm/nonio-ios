import SwiftUI

import SwiftUI

private struct PostTagView: View {
    
    var tag: PostTag
    
    var body: some View {
        Text(tag.tag)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(6)
            .foregroundColor(.blue)
            .background(UIColor.systemGray6.color)
            .cornerRadius(4)
    }
}

struct HorizontalTagsScrollView: View {
    var tags: [PostTag]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(tags, id: \.tagID) { tag in
                    PostTagView(tag: tag)
                }
            }
        }
    }
}

#Preview {
    HorizontalTagsScrollView(tags: [.init(postID: 1, tag: "funnyhahah", tagID: 2, score: 100), .init(postID: 2, tag: "tag22222", tagID: 3, score: 5), .init(postID: 1, tag: "longlonglonglonglonglonglonglonglong", tagID: 4, score: 0)])
}
