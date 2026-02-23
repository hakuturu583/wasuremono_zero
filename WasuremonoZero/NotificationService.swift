import Foundation
import UserNotifications

protocol UserNotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
}

extension UNUserNotificationCenter: UserNotificationCenterProtocol {}

struct NotificationAction {
    let identifier: String
    let title: String
}

final class NotificationService {
    static let categoryIdentifier = "CHECK_ITEMS"

    static let checkPhoneAction = NotificationAction(identifier: "CHECK_PHONE", title: "け")
    static let checkWalletAction = NotificationAction(identifier: "CHECK_WALLET", title: "さ")
    static let checkKeysAction = NotificationAction(identifier: "CHECK_KEYS", title: "キ")
    static let checkGlassesAction = NotificationAction(identifier: "CHECK_GLASSES", title: "め")
    static let snoozeAction = NotificationAction(identifier: "SNOOZE", title: "後で")

    private let notificationCenter: UserNotificationCenterProtocol

    init(notificationCenter: UserNotificationCenterProtocol = UNUserNotificationCenter.current()) {
        self.notificationCenter = notificationCenter
    }

    func configureCategories() {
        notificationCenter.setNotificationCategories([checkItemsCategory])
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    var checkItemsCategory: UNNotificationCategory {
        let actions = [
            NotificationService.checkPhoneAction,
            NotificationService.checkWalletAction,
            NotificationService.checkKeysAction,
            NotificationService.checkGlassesAction,
            NotificationService.snoozeAction
        ].map {
            UNNotificationAction(identifier: $0.identifier, title: $0.title)
        }

        return UNNotificationCategory(
            identifier: NotificationService.categoryIdentifier,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )
    }
}
