import Foundation
import Moya
import Combine

final class UserViewModel: ObservableObject {
    @Published private(set) var loading = false
    @Published private(set) var posts: String = ""
    @Published private(set) var postKarma: String = ""
    @Published private(set) var comments: String = ""
    @Published private(set) var commentKarma: String = ""

    let user: LoginResponse
    
    private let keychainService: KeychainServiceType
    private let provider = MoyaProvider.defaultProvider
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        user: LoginResponse,
        keychainService: KeychainServiceType = KeychainService()
    ) {
        self.user = user
        self.keychainService = keychainService
    }
    
    func logout() {
        try? keychainService.deleteUser()
    }
    
    func onload() {
        guard !loading else { return }
        
        loading = true
        provider.requestPublisher(.userInfo(user: user.username))
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
