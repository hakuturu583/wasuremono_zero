import CoreLocation
import Foundation

protocol CLLocationManaging: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }

    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    func startMonitoringSignificantLocationChanges()
    func startMonitoringVisits()
    func stopMonitoringSignificantLocationChanges()
    func stopMonitoringVisits()
}

extension CLLocationManager: CLLocationManaging {}

protocol LocationServiceDelegate: AnyObject {
    func locationService(_ service: LocationService, didUpdateLocations locations: [CLLocation])
    func locationService(_ service: LocationService, didVisit visit: CLVisit)
    func locationService(_ service: LocationService, didChangeAuthorization status: CLAuthorizationStatus)
}

final class LocationService: NSObject {
    weak var delegate: LocationServiceDelegate?

    private let locationManager: CLLocationManaging

    init(locationManager: CLLocationManaging = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
    }

    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    func requestPermissions() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    func startMonitoring() {
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringVisits()
    }

    func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopMonitoringVisits()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationService(self, didChangeAuthorization: manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationService(self, didUpdateLocations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        delegate?.locationService(self, didVisit: visit)
    }
}
