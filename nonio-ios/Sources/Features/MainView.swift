import SwiftUI
import Kingfisher

struct MainView: View {
    struct TabItemTag {
        static let posts = 1
        static let user = 3
        static let login = 4
        static let other = 5
    }

    @State private var selection = TabItemTag.posts
    @EnvironmentObject var settings: AppSettings
    
    var body: some View {
        TabView(selection: $selection) {
            PostsScreen(viewModel: PostsViewModel())
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
            
            if let user = settings.currentUser {
                userTab(user: user)
            } else {
                LoginScreen()
                    .tabItem {
                        makeTabItem(title: "Login", image: R.image.tabsUser.image)
                    }
                    .tag(TabItemTag.login)
            }
            
            SettingsScreen()
                .tabItem {
                    makeTabItem(title: "Settings", image: R.image.tabsSettings.image)
                }
                .tag(TabItemTag.other)
        }
        .onChange(of: selection) { selectedTab in
            if selectedTab == TabItemTag.user || selectedTab == TabItemTag.login {
                
            } else {
                // Restrict tab selection to only the first tab, disabling others.
                selection = TabItemTag.posts
            }
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
    
    @ViewBuilder
    func userTab(user: LoginResponse) -> some View {
        UserScreen(param: .login(user))
            .tabItem {
//                userAvatar(user: user.username)
                Icon(image: R.image.tabsUser.image, size: .small)

                Text(user.username)
            }
            .tag(TabItemTag.user)
        
    }
    
    private func userAvatar(user: String) -> some View {
        KFImage(ImageURLGenerator.userAvatarURL(user: user))
            .placeholder {
                Icon(image: R.image.add.image, size: .small)
            }
            .onSuccess { r in print("success: \(r)") }
            .setProcessor(ResizingImageProcessor(referenceSize: CGSize(width: 16 , height: 16), mode: .aspectFit) |> RoundCornerImageProcessor(cornerRadius: 8))
            .frame(width: 16, height: 16)
    }
}

#Preview {
    MainView()
}
