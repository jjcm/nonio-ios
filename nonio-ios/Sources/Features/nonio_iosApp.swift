import SwiftUI

@main
struct nonio_iosApp: App {
    private let appSettings = AppSettings()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appSettings)
        }
    }
}
