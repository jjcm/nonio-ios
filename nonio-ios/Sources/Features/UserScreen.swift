import SwiftUI
import Kingfisher

struct UserScreen: View {
    
    enum Route {
        case posts
        case comments
    }
    
    @EnvironmentObject var settings: AppSettings
    @StateObject var viewModel: UserViewModel
    @State private var selectedRoute: Route?

    init(param: UserViewParamType) {
        self._viewModel = .init(wrappedValue: UserViewModel(param: param))
    }
    
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
            List {
                avatarView
                
                contentSection
                    .padding(.top, 20)
                
                statsSection
                    .padding(.top, 24)
                
                Button {
                    settings.currentUser = nil
                    viewModel.logout()
                } label: {
                    Text("Logout")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(UIColor.secondarySystemBackground.color)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 24)
                .plainListItem()
                .showIf(viewModel.showLogoutButton)
            }
            .navigationDestination(for: $selectedRoute, destination: { route in
                switch route {
                case .comments:
                    EmptyView()
                case .posts:
                    PostsScreen(viewModel: .init(user: viewModel.param.username))
                }
            })
            .navigationTitle(viewModel.param.username)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Account")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .refreshable {
                viewModel.onload()
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .listRowSeparator(.hidden)
        }
        .onLoad {
            viewModel.onload()
        }

    }
    
    var contentSection: some View {
        VStack(alignment: .leading) {
            Text("CONTENT")
                .foregroundStyle(.secondary)
                .font(.system(size: 13))
                .frame(height: 23)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                Button {
                    selectedRoute = .posts
                } label: {
                    row(
                        title: "Posts",
                        value: viewModel.posts,
                        icon: R.image.postBlue.image,
                        showIndicator: true
                    )
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading)
                                        
                row(
                    title: "Comments",
                    value: viewModel.comments,
                    icon: R.image.commentBlue.image,
                    showIndicator: false
                )
            }
            .background(UIColor.secondarySystemBackground.color)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .plainListItem()
    }
    
    var statsSection: some View {
        VStack(alignment: .leading) {
            Text("STATS")
                .foregroundStyle(.secondary)
                .font(.system(size: 13))
                .frame(height: 23)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                row(
                    title: "Post Karma",
                    value: viewModel.postKarma,
                    icon: R.image.postBlue.image,
                    showIndicator: false
                )
                
                Divider()
                    .padding(.leading)
                                        
                row(
                    title: "Comment Karma",
                    value: viewModel.commentKarma,
                    icon: R.image.commentBlue.image,
                    showIndicator: false
                )
            }
            .background(UIColor.secondarySystemBackground.color)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .plainListItem()
    }
    
    func row(
        title: String,
        value: String,
        icon: Image,
        showIndicator: Bool
    ) -> some View {
        HStack {
            icon

            Text(title)
                .padding(.leading, 16)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Icon(image: R.image.chevronRight.image, size: .big)
                .showIf(showIndicator)
                .frame(width: 16)
                .offset(x: 4)
        }
        .frame(height: 44)
        .padding(.horizontal, 16)
    }
    
    var avatarView: some View {
        VStack(alignment: .center, spacing: 10) {
            KFImage(ImageURLGenerator.userAvatarURL(user: viewModel.param.username))
                .placeholder {
                    Icon(image: R.image.tabsUser.image, size: .small)
                }
                .resizable()
                .frame(width: 62, height: 62)
                .clipShape(Circle())
            
            Text(viewModel.param.username)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
}

#Preview {
    UserScreen(param: .user("jjcm"))
}
