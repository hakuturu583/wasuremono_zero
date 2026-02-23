import Foundation

final class SettingsStore {
    private enum Key {
        static let enabledItems = "settings.enabledItems"
        static let minimumIntervalMinutes = "settings.minimumIntervalMinutes"
        static let minimumDistanceMeters = "settings.minimumDistanceMeters"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> AppSettings {
        var settings = AppSettings.default

        if let rawItems = userDefaults.array(forKey: Key.enabledItems) as? [String] {
            let items = rawItems.compactMap(CheckItem.init(rawValue:))
            if items.isEmpty == false {
                settings.enabledItems = Set(items)
            }
        }

        let interval = userDefaults.integer(forKey: Key.minimumIntervalMinutes)
        if interval > 0 {
            settings.minimumIntervalMinutes = interval
        }

        let distance = userDefaults.double(forKey: Key.minimumDistanceMeters)
        if distance > 0 {
            settings.minimumDistanceMeters = distance
        }

        return settings
    }

    func save(_ settings: AppSettings) {
        userDefaults.set(settings.enabledItems.map(\.rawValue), forKey: Key.enabledItems)
        userDefaults.set(settings.minimumIntervalMinutes, forKey: Key.minimumIntervalMinutes)
        userDefaults.set(settings.minimumDistanceMeters, forKey: Key.minimumDistanceMeters)
    }
}
