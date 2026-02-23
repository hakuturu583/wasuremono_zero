import Foundation

struct AppSettings: Equatable {
    var enabledItems: Set<CheckItem>
    var minimumIntervalMinutes: Int
    var minimumDistanceMeters: Double

    static let `default` = AppSettings(
        enabledItems: Set(CheckItem.allCases),
        minimumIntervalMinutes: 30,
        minimumDistanceMeters: 200
    )
}
