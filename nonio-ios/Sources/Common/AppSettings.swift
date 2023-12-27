import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var currentUser: LoginResponse?
    
    var hasLoggedIn: Bool {
        currentUser != nil
    }
    
    init(keychainService: KeychainServiceType = KeychainService()) {
        currentUser = try? keychainService.getUser()
    }
}
