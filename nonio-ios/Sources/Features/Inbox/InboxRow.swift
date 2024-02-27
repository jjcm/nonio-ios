import SwiftUI

struct InboxRow: View {

    private let viewModel: InboxRowViewModel
    init(notification: InboxNotification) {
        self.viewModel = .init(notification: notification)
    }

    var body: some View {
        VStack(alignment: .leading) {
            userView
        }
        .padding(.vertical, 10)
        .background(UIColor.systemBackground.color)
    }

    var userView: some View {
        PostUserView(
            viewModel: viewModel.userViewModel,
            commentVotesViewModel: viewModel.commentVotesViewModel,
            didTapUserProfileAction: {

            }
        )
    }
}
