import SwiftUI

@main
struct nonio_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let appSettings = AppSettings()
    private let votingService = UserVotingService()
    private let notificationDataTicker = NotificationUnreadTicker()
    @StateObject var alertInteractor = GlobalAlertObject()

    var body: some Scene {
        WindowGroup {}
    }
}

struct MainView: View {
    private let appSettings = AppSettings()
    private let votingService = UserVotingService()
    private let notificationDataTicker = NotificationUnreadTicker()
    @StateObject var alertInteractor = GlobalAlertObject()

    var body: some View {
        AppTabView()
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
