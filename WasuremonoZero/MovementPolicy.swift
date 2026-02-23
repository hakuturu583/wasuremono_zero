import CoreLocation
import Foundation

struct MovementPolicy {
    var minimumInterval: TimeInterval = 30 * 60
    var minimumDistance: CLLocationDistance = 200

    func shouldNotify(
        lastNotifiedAt: Date?,
        lastLocation: CLLocation?,
        newLocation: CLLocation,
        now: Date = Date()
    ) -> Bool {
        guard let lastLocation else {
            return true
        }

        let movedDistance = newLocation.distance(from: lastLocation)
        if movedDistance >= minimumDistance {
            return true
        }

        guard let lastNotifiedAt else {
            return false
        }

        return now.timeIntervalSince(lastNotifiedAt) >= minimumInterval
    }
}
