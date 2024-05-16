

import Foundation
import Combine
import SwiftUI
import Moya
import KeychainAccess

final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var loading = false
    @Published private(set) var loginButtonDisabled = true
    @Published var showErrorAlert = false
    @Published private(set) var loginResponse: LoginResponse?
        
    private var cancellables: Set<AnyCancellable> = []
    private let provider = MoyaProvider<NonioAPI>(plugins: [NetworkLoggerPlugin()])
    private let keychainService: KeychainServiceType
    private let notificationCenter: NotificationCenter

    init(
        keychainService: KeychainServiceType = KeychainService(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.keychainService = keychainService
        self.notificationCenter = notificationCenter

        Publishers
            .CombineLatest($email, $password)
            .sink { email, password in
                self.loginButtonDisabled = email.isEmpty || password.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func loginAction() {
        guard !email.isEmpty, !password.isEmpty else { return }
        guard !loading else { return }
        
        loading = true
        provider.requestPublisher(.login(user: email, password: password))
            .map(LoginResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.showErrorAlert = true
                }
                self.loading = false
            }, receiveValue: { response in
                self.handleResponse(response)
                self.notificationCenter.post(name: .UserDidLogin, object: nil)
            })
            .store(in: &cancellables)
    }

    func handleResponse(_ response: LoginResponse) {
        loginResponse = response
        try? keychainService.saveUser(response)
    }
}
