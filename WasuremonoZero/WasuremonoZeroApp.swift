import SwiftUI

@main
struct WasuremonoZeroApp: App {
    private let notificationService = NotificationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    notificationService.configure()
                    _ = await notificationService.requestAuthorization()
                }
        }
    }
}
