import CoreLocation
import SwiftUI

@main
struct WasuremonoZeroApp: App {
    @StateObject private var appCoordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    appCoordinator.start()
                }
        }
    }
}

final class AppCoordinator: NSObject, ObservableObject {
    private let notificationService: NotificationService
    private let locationService: LocationService

    override init() {
        let notificationService = NotificationService()
        let locationService = LocationService()

        self.notificationService = notificationService
        self.locationService = locationService

        super.init()
        self.locationService.delegate = self
    }

    func start() {
        notificationService.configureCategories()
        locationService.requestPermissions()
        startLocationMonitoringIfAuthorized()
    }

    private func startLocationMonitoringIfAuthorized() {
        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationService.startMonitoring()
        default:
            break
        }
    }
}

extension AppCoordinator: LocationServiceDelegate {
    func locationService(_ service: LocationService, didUpdateLocations locations: [CLLocation]) {}

    func locationService(_ service: LocationService, didVisit visit: CLVisit) {}

    func locationService(_ service: LocationService, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocationMonitoringIfAuthorized()
        if status == .authorizedWhenInUse {
            locationService.requestPermissions()
        }
    }
}
