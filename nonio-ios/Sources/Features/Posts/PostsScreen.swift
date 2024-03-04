import SwiftUI
import Combine

struct PostsScreen: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject var viewModel: PostsViewModel
    @State private var showSortTimeframeActionSheet = false
    @State private var showSortActionSheet = false
    @State private var selectedUser: String?
    @State private var selectedPost: Post?
    
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
            ScrollViewReader { proxy in
                List(viewModel.posts, id: \.ID) { post in
                    rowItem(post)
                        .id(post.ID)
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
                    viewModel.fetchVotes(hasLoggedIn: settings.hasLoggedIn)
                }
                .onChange(of: viewModel.displayTag, perform: { _ in
                    proxy.scrollTo(viewModel.posts.first?.ID)
                })
                .background(UIColor.secondarySystemBackground.color)
                .navigationDestination(for: $selectedUser) { user in
                    UserScreen(param: .user(user))
                }
                .navigationTitle(viewModel.title)
                .navigationDestination(for: $selectedPost) { post in
                    PostDetailsScreen(
                        viewModel: .init(
                            postURL: post.url,
                            votes: viewModel.votes,
                            provider: viewModel.provider
                        )
                    )
                }
            }
        }
        .onChange(of: settings.hasLoggedIn, perform: { hasLoggedIn in
            viewModel.fetchVotes(hasLoggedIn: hasLoggedIn)
        })
        .onLoad {
            viewModel.fetch()
            viewModel.fetchVotes(hasLoggedIn: settings.hasLoggedIn)
        }
    }
    
    @ViewBuilder
    func rowItem(_ post: Post) -> some View {
        Button {
            selectedPost = post
        } label: {
            PostRowView(
                viewModel: .init(post: post),
                votes: viewModel.votes,
                didTapUserProfileAction: {
                    selectedUser = post.user
                },
                didTapPostLink: {
                    post in
                    viewModel.didTapPostLink(post: post)
                })
        }
        .plainListItem()
    }
    
    @ToolbarContentBuilder
    func toolbarItems() -> some ToolbarContent {
        if !viewModel.isUserPosts {
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
        }
        
        ToolbarItem(placement: .principal) {
            Text(viewModel.title)
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
