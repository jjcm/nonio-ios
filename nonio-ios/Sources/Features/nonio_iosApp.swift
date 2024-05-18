import SwiftUI

@main
struct nonio_iosApp: App {
    private let appSettings = AppSettings()
    private let notificationDataTicker = NotificationUnreadTicker()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appSettings)
                .environmentObject(notificationDataTicker)
        }
    }
}
