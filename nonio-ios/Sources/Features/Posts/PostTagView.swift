import SwiftUI

struct PostTagView: View {
    @EnvironmentObject var settings: AppSettings

    let tag: PostTag
    let voted: Bool
    let textColor: Color
    let toggleVoteAction: (() -> Void)
    let onTap: ((PostTag) -> Void)
    init(
        tag: PostTag,
        voted: Bool,
        textColor: Color,
        toggleVoteAction: @escaping () -> Void,
        onTap: @escaping ((PostTag)) -> Void
    ) {
        self.tag = tag
        self.voted = voted
        self.textColor = textColor
        self.toggleVoteAction = toggleVoteAction
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            Button {
                toggleVoteAction()
            } label: {
                if settings.hasLoggedIn {
                    Icon(image: R.image.upvote.image, size: .small)
                        .tint(voted ? Style.votedColor : Style.normalTextColor)
                }
                Text("\(tag.score)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(voted ? Style.votedColor : Style.normalTextColor)
            }
            .padding(6)
            .showIf(tag.score > 0)
            
            Button {
                onTap(tag)
            } label: {
                Text(tag.tag)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(textColor)
                    .padding(.horizontal, 8)
                    .cornerRadius(2)
                    .frame(maxHeight: .infinity)
                    .background(Style.tagBGColor)
            }
        }
        .background(Style.bgColor)
        .cornerRadius(8)
    }
}

extension PostTagView {
    struct Style {
        static let votedColor = Color.red
        static let normalTextColor = Color.dynamicColor(
            light: Color(red: 0.1, green: 0.1, blue: 0.1),
            dark: Color(red: 0.92, green: 0.92, blue: 0.96).opacity(0.6)
        )
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

extension HorizontalTagsScrollView {
    struct Style {
        let height: CGFloat
        let textColor: Color

        static let `default` = Style(height: 28, textColor: .blue)
    }
}

struct HorizontalTagsScrollView: View {
    @StateObject var viewModel: PostTagViewModel
    @EnvironmentObject var userVotingService: UserVotingService
    let post: String?
    let style: Style
    let onTap: ((PostTag) -> Void)
    init(
        post: String?,
        viewModel: PostTagViewModel,
        style: Style = .default,
        onTap: @escaping ((PostTag)) -> Void = { _ in }
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.style = style
        self.onTap = onTap
        self.post = post
    }
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.tags, id: \.tagID) { tag in
                    let voted = viewModel.isVoted(tag: tag, service: userVotingService)
                    PostTagView(tag: tag, voted: voted, textColor: style.textColor) {
                        viewModel.toggleVote(post: post, tag: tag, vote: !voted)
                    } onTap: { tag in
                        onTap(tag)
                    }
                    .frame(height: style.height)
                }
            }
        }
        .onLoad {
            viewModel.userVotingService = userVotingService
        }
    }
}

#Preview {
    VStack {
        HorizontalTagsScrollView(
            post: nil,
            viewModel: .init(tags: [
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
            ])
        )
    }
    .padding()
    .environmentObject(AppSettings())
}
