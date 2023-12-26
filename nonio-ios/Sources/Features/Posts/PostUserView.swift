import SwiftUI
import Kingfisher

struct PostUserView: View {
    let viewModel: PostUserViewModel
    let isCollapsed: Bool
    init(viewModel: PostUserViewModel, isCollapsed: Bool = false) {
        self.viewModel = viewModel
        self.isCollapsed = isCollapsed
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                KFImage(ImageURLGenerator.userAvatarURL(user: viewModel.user))
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
                    .layoutPriority(1)
                
                Text(viewModel.user)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Text(viewModel.scoreString)
                    .foregroundColor(.gray)
                
                if let dateString = viewModel.dateString, !isCollapsed {
                    HStack(spacing: 4) {
                        Icon(image: R.image.clock.image, size: .small)
                        Text(dateString)
                    }
                }
                
                HStack(spacing: 4) {
                    Icon(image: R.image.comment.image, size: .small)
                    Text(viewModel.commentString)
                }
                .showIf(viewModel.showCommentCount)
                
                Icon(image: R.image.chervronDown.image, size: .small)
                    .foregroundColor(.secondary)
                    .showIf(isCollapsed)
            }
            .foregroundColor(UIColor.darkGray.color)
            .layoutPriority(1)
        }
        .font(.subheadline)
        .cornerRadius(10)
    }
}
