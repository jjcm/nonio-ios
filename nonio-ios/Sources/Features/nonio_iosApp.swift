import SwiftUI

@main
struct nonio_iosApp: App {
    private let appSettings = AppSettings()
    private let votingService = UserVotingService()
    private let notificationDataTicker = NotificationUnreadTicker()
    @StateObject var alertInteractor = GlobalAlertObject()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appSettings)
                .environmentObject(notificationDataTicker)
                .environmentObject(votingService)
                .environmentObject(alertInteractor)
                .onLoad {
                    if appSettings.hasLoggedIn {
                        votingService.fetchVotes()
                    }
                }
                .alert(isPresented: $alertInteractor.isShowingAlert) {
                    alertInteractor.alert ?? Alert(title: Text(""))
                }
        }
    }
}
