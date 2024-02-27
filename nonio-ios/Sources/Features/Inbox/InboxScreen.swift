import SwiftUI

struct InboxScreen: View {
    @StateObject var viewModel: InboxViewModel

    var body: some View {
        ZStack {
            content

            if viewModel.loading {
                ProgressView()
            }
        }
    }

    var content: some View {
        NavigationStack {
            List(viewModel.models, id: \.self) { model in
                VStack {
                    InboxRow(notification: model)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                viewModel.fetch()
            }
        }
        .onLoad {
            viewModel.fetch()
        }
    }
}

#Preview {
    InboxScreen(viewModel: .init())
}
