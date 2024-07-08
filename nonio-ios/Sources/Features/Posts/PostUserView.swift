import SwiftUI
import Kingfisher

struct PostUserView: View {
    
    @EnvironmentObject var settings: AppSettings
    @ObservedObject var viewModel: PostUserViewModel
    @ObservedObject var commentVotesViewModel: CommentVotesViewModel
    
    let isCollapsed: Bool
    let didTapUserProfileAction: (() -> Void)
    let upvoteAction: (() -> Void)?
    init(
        viewModel: PostUserViewModel,
        commentVotesViewModel: CommentVotesViewModel,
        isCollapsed: Bool = false,
        didTapUserProfileAction: @escaping (() -> Void),
        upvoteAction: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.commentVotesViewModel = commentVotesViewModel
        self.isCollapsed = isCollapsed
        self.didTapUserProfileAction = didTapUserProfileAction
        self.upvoteAction = upvoteAction
    }
    
    var body: some View {
        HStack {
            Button {
                didTapUserProfileAction()
            } label: {
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
                    
                    HStack(spacing: 4) {
                        Text(viewModel.user)
                            .foregroundColor(UIColor.label.color)
                            .fontWeight(viewModel.isReply ? .semibold : .regular)
                            .lineLimit(2)

                        if let userText = viewModel.actionText {
                            Text(userText)
                                .foregroundColor(viewModel.read ? UIColor.secondaryLabel.color : UIColor.label.color)
                                .fontWeight(.regular)
                                .lineLimit(1)
                        }
                    }

                }
                .font(.system(size: 13))
            }
            .buttonStyle(.plain)

            Spacer()
            
            HStack(spacing: 12) {
                let voted = commentVotesViewModel.isCommentVoted(comment: viewModel.commentID)  == true
                Button {
                    upvoteAction?()
                } label: {
                    HStack(spacing: 2) {
                        if settings.hasLoggedIn {
                            Icon(image: R.image.upvote.image, size: .small)
                                .foregroundStyle(voted ? Style.votedColor : Style.normalTextColor)
                                .showIf(settings.hasLoggedIn && upvoteAction != nil)
                        }
                        if let upvotesString = viewModel.upvotesString {
                            Text(upvotesString)
                                .foregroundStyle(Style.normalTextColor)
                        }
                    }
                }
                .disabled(upvoteAction == nil || voted)
                
                if let dateString = viewModel.dateString, !isCollapsed {
                    HStack(spacing: 4) {
                        Icon(image: R.image.clock.image, size: .small)
                        Text(dateString)
                    }
                    .foregroundColor(UIColor.secondaryLabel.color)
                    
                }
                
                HStack(spacing: 4) {
                    Icon(image: R.image.comment.image, size: .small)
                    Text(viewModel.commentString)
                }
                .foregroundColor(UIColor.secondaryLabel.color)
                .showIf(viewModel.showCommentCount)
                
                Icon(image: R.image.chervronDown.image, size: .small)
                    .foregroundColor(.secondary)
                    .showIf(isCollapsed)
            }
            .font(.system(size: 13))
            .foregroundColor(UIColor.darkGray.color)
            .layoutPriority(1)
        }
        .font(.subheadline)
        .cornerRadius(10)
    }
}

extension PostUserView {
    struct Style {
        static let votedColor = Color.red
        static let normalTextColor = Color.primary

        static let bgColor = Color.dynamicColor(
            light: Color(red: 0.96, green: 0.96, blue: 0.96),
            dark: Color(red: 0.17, green: 0.17, blue: 0.18)
        )
        static let tagBGColor = Color.dynamicColor(
            light:  Color(red: 0.9, green: 0.9, blue: 0.9),
            dark: Color(red: 0.11, green: 0.11, blue: 0.12)
        )
    }
}

#Preview {
    VStack{
        PostUserView(
            viewModel: .init(
                comment: .init(
                    id: 1,
                    date: 1717334831000,
                    post: "post",
                    postTitle: "title",
                    content: "{\"ops\":[{\"insert\":\"test comment\"},{\"attributes\":{\"blockquote\":true},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]}",
                    user: "user",
                    upvotes: 10,
                    downvotes: 1,
                    parent: -1,
                    lineageScore: 10,
                    descendentCommentCount: 20,
                    edited: false
                ),
                upvotesString: "10",
                showUpvoteCount: true
            ),
            commentVotesViewModel: .init(postURL: "url"),
            isCollapsed: false,
            didTapUserProfileAction: {},
            upvoteAction: { }
        )
        .padding()
        .environmentObject(AppSettings())
    }
}
