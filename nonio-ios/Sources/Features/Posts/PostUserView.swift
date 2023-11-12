import SwiftUI
import Kingfisher

struct PostUserView: View {
    let post: Post
    let viewModel: PostUserViewModel
    init(post: Post) {
        self.post = post
        self.viewModel = PostUserViewModel(post: post)
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                KFImage(ImageURLGenerator.userAvatarURL(user: post.user))
                    .resizable()
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
                    .layoutPriority(1)
                
                Text(post.user)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text(viewModel.scoreString)
                    .foregroundColor(.primary)
                
                if let dateString = viewModel.dateString {
                    HStack(spacing: 4) {
                        Icon(image: R.image.clock.image, size: .small)
                        Text(dateString)
                    }
                }
                
                HStack(spacing: 4) {
                    Icon(image: R.image.comment.image, size: .small)
                    Text(viewModel.commentString)
                }
            }
            .foregroundColor(.gray)
            .layoutPriority(1)
        }
        .font(.subheadline)
        .padding(.vertical, 10)
        .cornerRadius(10)
    }
}


#Preview {
    PostUserView(post: .init(id: 1, title: "", user: "jjcm", time: 1699151931000, url: "", link: nil, type: .blog, content: "", score: 11, commentCount: 12, tags: []))
}
