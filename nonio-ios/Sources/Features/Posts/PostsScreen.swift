import SwiftUI
import Combine

struct PostsScreen: View {
    @StateObject var viewModel: PostsViewModel
    @State private var showSortTimeframeActionSheet = false
    @State private var showSortActionSheet = false
    
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
            List(viewModel.posts, id: \.ID) { post in
                rowItem(post)
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .toolbar {
                toolbarItems()
            }
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Sort by...", isPresented: $showSortActionSheet, titleVisibility: .visible) {
                sortButtons()
            }
            .confirmationDialog("Top sort timeframe", isPresented: $showSortTimeframeActionSheet, titleVisibility: .visible) {
                timeFrameButtons()
            }
            .refreshable {
                viewModel.fetch()
            }
            .background(UIColor.secondarySystemBackground.color)
        }
        .onAppear {
            viewModel.fetch()
        }
    }
    
    @ViewBuilder
    func rowItem(_ post: Post) -> some View {
        NavigationLink {
            PostDetailView(post: post)
        } label: {
            PostView(viewModel: .init(post: post), didTapPostLink: { post in
                viewModel.didTapPostLink(post: post)
            })
        }
        .plainListItem()
    }
    
    @ToolbarContentBuilder
    func toolbarItems() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink(destination: TagsScreen(viewModel: viewModel.tagsViewModel) { tag in
                self.viewModel.onSelectTag(tag)
            } didSelectAll: {
                self.viewModel.onSelectAllPosts()
            }, label: {
                Icon(image: R.image.tag.image, size: .medium)
            })
            .navigationTitle("Posts")
        }
        
        ToolbarItem(placement: .principal) {
            Text(viewModel.displayTag)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showSortActionSheet = true
            } label: {
                Icon(image: R.image.sort.image, size: .medium)
            }
        }
    }
    
    @ViewBuilder
    func sortButtons() -> some View {
        ForEach(GetPostParams.Sort.allCases, id: \.rawValue) { sort in
            Button(sort.display) {
                switch sort {
                case .top:
                    showSortTimeframeActionSheet = true
                default:
                    viewModel.onSelectSortOption(sort)
                }
            }
        }
    }
    
    @ViewBuilder
    func timeFrameButtons() -> some View {
        ForEach(GetPostParams.Time.allCases, id: \.rawValue) { time in
            Button(time.display) { viewModel.onSelectTimeframe(time) }
        }
    }
}

#Preview {
    PostsScreen(viewModel: .init())
}
