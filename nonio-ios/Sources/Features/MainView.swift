import SwiftUI
import Kingfisher

struct MainView: View {
    struct TabItemTag {
        static let posts = 1
        static let inbox = 2
        static let user = 3
        static let login = 4
        static let submission = 5
        static let other = 6
    }

    @State private var selection = TabItemTag.posts
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var notificationDataTicker: NotificationUnreadTicker
    @State private var avatar: UIImage?

    var body: some View {
        TabView(selection: $selection) {
            PostsScreen(viewModel: PostsViewModel())
                .tabItem {
                    makeTabItem(title: "Posts", image: R.image.tabsPosts.image)
                }
                .tag(TabItemTag.posts)
            
            InboxScreen(viewModel: InboxViewModel())
                .tabItem {
                    makeTabItem(title: "Inbox", image: R.image.tabsInbox.image)
                }
                .tag(TabItemTag.inbox)
                .badge(notificationDataTicker.unreadCount)

            PostSubmissionScreen()
                .tabItem {
                    makeTabItem(title: "Submit", image: R.image.tabsSubmit.image)
                }
                .tag(TabItemTag.submission)
            
            if let user = settings.currentUser {
                userTab(avatar: avatar, user: user)
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
        .onLoad {
            guard let user = settings.currentUser else { return }
            fetchAvatar(user: user)
        }
        .onChange(of: settings.currentUser, { oldValue, user in
            guard let user else { return }
            fetchAvatar(user: user)
        })
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
    func userTab(avatar: UIImage?, user: LoginResponse) -> some View {
        UserScreen(param: .login(user))
            .tabItem {
                TabIcon(icon: avatar ?? UIImage(), size: CGSize(width: 24, height: 24))
                Text(user.username)
            }
            .tag(TabItemTag.user)
    }

    private func fetchAvatar(user: LoginResponse) {
        KingfisherManager.shared.retrieveImage(
            with: ImageURLGenerator.userAvatarURL(user: user.username),
            options: [.forceRefresh]
        ) { result in
            switch result {
            case .success(let result):
                avatar = result.image
            default:
                break
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(
            AppSettings(
                user: .init(
                    accessToken: "",
                    refreshToken: "",
                    username: "jjcm"
                )
            )
        )
        .environmentObject(NotificationUnreadTicker())
}
