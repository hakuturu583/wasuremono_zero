import CoreLocation
import SwiftUI
import UIKit

@main
struct WasuremonoZeroApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let appCoordinator = AppCoordinator()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        appCoordinator.start()
        return true
    }
}

final class AppCoordinator: NSObject {
    private let notificationService: NotificationService
    private let locationService: LocationService
    private let movementPolicy = MovementPolicy()

    private var lastNotifiedAt: Date?
    private var lastLocation: CLLocation?
    private var hasStarted = false

    override init() {
        let notificationService = NotificationService()
        let locationService = LocationService()

        self.notificationService = notificationService
        self.locationService = locationService

        super.init()
        self.locationService.delegate = self
    }

    func start() {
        guard hasStarted == false else {
            return
        }

        hasStarted = true
        notificationService.configureCategories()
        Task {
            _ = await notificationService.requestAuthorization()
        }
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
    func locationService(_ service: LocationService, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        handleMovementEvent(location: location)
    }

    func locationService(_ service: LocationService, didVisit visit: CLVisit) {
        let coordinate = visit.coordinate
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            return
        }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        handleMovementEvent(location: location)
    }

    func locationService(_ service: LocationService, didChangeAuthorization status: CLAuthorizationStatus) {
        startLocationMonitoringIfAuthorized()
        if status == .authorizedWhenInUse {
            locationService.requestPermissions()
        }
    }

    private func handleMovementEvent(location: CLLocation) {
        let now = Date()
        guard movementPolicy.shouldNotify(
            lastNotifiedAt: lastNotifiedAt,
            lastLocation: lastLocation,
            newLocation: location,
            now: now
        ) else {
            return
        }

        lastNotifiedAt = now
        lastLocation = location

        Task {
            await notificationService.scheduleCheckNotification()
        }
    }
}
