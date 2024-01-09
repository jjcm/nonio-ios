import Foundation
import Moya
import Combine

enum UserViewParamType {
    /// Logined in user
    case login(LoginResponse)
    
    /// User id
    case user(String)
    
    var username: String {
        switch self {
        case .login(let loginResponse): return loginResponse.username
        case .user(let user): return user
        }
    }
}

final class UserViewModel: ObservableObject {
    @Published private(set) var loading = false
    @Published private(set) var posts: String = ""
    @Published private(set) var postKarma: String = ""
    @Published private(set) var comments: String = ""
    @Published private(set) var commentKarma: String = ""
    
    var showLogoutButton: Bool {
        switch param {
        case .login: return true
        case .user: return false
        }
    }

    let param: UserViewParamType
    
    private let keychainService: KeychainServiceType
    private let provider = MoyaProvider.defaultProvider
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        param: UserViewParamType,
        keychainService: KeychainServiceType = KeychainService()
    ) {
        self.param = param
        self.keychainService = keychainService
    }
    
    func logout() {
        try? keychainService.deleteUser()
    }
    
    func onload() {
        guard !loading else { return }
        
        loading = true
        provider.requestPublisher(.userInfo(user: param.username))
            .map(UserInfo.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    break
                }
                self.loading = false
            }, receiveValue: { userInfo in
                self.posts = userInfo.posts.description
                self.postKarma = userInfo.karma.description
                self.comments = userInfo.comments.description
                self.commentKarma = userInfo.comment_karma.description
            })
            .store(in: &cancellables)
    }
}
