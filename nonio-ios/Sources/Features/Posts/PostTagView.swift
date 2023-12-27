import SwiftUI

import SwiftUI

private struct PostTagView: View {
    @EnvironmentObject var settings: AppSettings

    let tag: PostTag
    let voted: Bool
    let toggleVoteAction: (() -> Void)
    init(tag: PostTag, voted: Bool, toggleVoteAction: @escaping () -> Void) {
        self.tag = tag
        self.voted = voted
        self.toggleVoteAction = toggleVoteAction
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
            
            Text(tag.tag)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(6)
                .background(Style.tagBGColor)
                .cornerRadius(2)
        }
        .padding(2)
        .background(Style.bgColor)
        .cornerRadius(2)
    }
}

private extension PostTagView {
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

struct HorizontalTagsScrollView: View {
    @ObservedObject var viewModel: PostTagViewModel
    init(post: String, tags: [PostTag], votes: [Vote]) {
        self.viewModel = PostTagViewModel(post: post, tags: tags, votes: votes)
    }
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.tags, id: \.tagID) { tag in
                    let voted = viewModel.isVoted(tag: tag)
                    PostTagView(tag: tag, voted: voted) {
                        viewModel.toggleVote(tag: tag, vote: !voted)
                    }
                }
            }
        }
    }
}
