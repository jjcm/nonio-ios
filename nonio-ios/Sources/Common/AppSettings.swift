import SwiftUI

class AppSettings: ObservableObject {
    @Published var currentUser: LoginResponse?

    init(user: LoginResponse) {
        currentUser = user
    }

    var hasLoggedIn: Bool {
        currentUser != nil
    }
    
    init(keychainService: KeychainServiceType = KeychainService()) {
        currentUser = try? keychainService.getUser()
    }
}
