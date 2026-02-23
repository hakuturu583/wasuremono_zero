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
        if let lastNotifiedAt,
           now.timeIntervalSince(lastNotifiedAt) < minimumInterval {
            return false
        }

        if let lastLocation,
           newLocation.distance(from: lastLocation) < minimumDistance {
            return false
        }

        return true
    }
}
