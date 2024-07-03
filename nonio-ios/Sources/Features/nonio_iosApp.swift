import SwiftUI

@main
struct nonio_iosApp: App {
    private let appSettings = AppSettings()
    private let votingService = UserVotingService()
    private let notificationDataTicker = NotificationUnreadTicker()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appSettings)
                .environmentObject(notificationDataTicker)
                .environmentObject(votingService)
                .onLoad {
                    if appSettings.hasLoggedIn {
                        votingService.fetchVotes()
                    }
                }
        }
    }
}
