import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var currentUser: LoginResponse?
    
    init(keychainService: KeychainServiceType = KeychainService()) {
        currentUser = try? keychainService.getUser()
    }
}
