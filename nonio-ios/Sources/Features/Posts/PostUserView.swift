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
                    
                    HStack {
                        Text(viewModel.user)
                            .foregroundColor(UIColor.label.color)
                            .fontWeight(viewModel.isReply ? .semibold : .regular)
                            .lineLimit(2)

                        if let userText = viewModel.actionText {
                            Text(userText)
                                .foregroundColor(viewModel.read ? UIColor.secondaryLabel.color : UIColor.label.color)
                                .fontWeight(viewModel.isReply ? .semibold : .regular)
                                .lineLimit(2)
                        }
                    }

                }
            }
            .buttonStyle(.plain)

            Spacer()
            
            HStack(spacing: 12) {
                let voted = commentVotesViewModel.isCommentVoted(comment: viewModel.commentID)  == true
                Button {
                    upvoteAction?()
                } label: {
                    HStack {
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
