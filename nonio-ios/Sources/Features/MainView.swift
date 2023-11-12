import SwiftUI

struct MainView: View {
    struct TabItemTag {
        static let posts = 1
        static let other = 2
    }
    private let postsViewModel = PostsViewModel()
    @State private var selection = TabItemTag.posts
    
    var body: some View {
        TabView(selection: $selection) {
            PostsScreen(viewModel: postsViewModel)
                .tabItem {
                    makeTabItem(title: "Posts", image: R.image.tabsPosts.image)
                }
                .tag(TabItemTag.posts)
            
            InboxScreen()
                .tabItem {
                    makeTabItem(title: "Inbox", image: R.image.tabsInbox.image)
                }
                .tag(TabItemTag.other)
            
            SubmitScreen()
                .tabItem {
                    makeTabItem(title: "Submit", image: R.image.tabsSubmit.image)
                }
                .tag(TabItemTag.other)

            SettingsScreen()
                .tabItem {
                    makeTabItem(title: "Settings", image: R.image.tabsSettings.image)
                }
                .tag(TabItemTag.other)
        }
        .onChange(of: selection) { _ in
            // Restrict tab selection to only the first tab, disabling others.
            selection = TabItemTag.posts
        }
    }
    
    @ViewBuilder
    func makeTabItem(title: String, image: Image) -> some View {
        Label(
            title: {
                Text(title)
            },
            icon: {
                Icon(image: image, size: .medium)
            }
        )
    }
}

#Preview {
    MainView()
}
