import Foundation
import UserNotifications

protocol UserNotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func setNotificationCategories(_ categories: Set<UNNotificationCategory>)
    func add(_ request: UNNotificationRequest) async throws
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

    func configure() {
        let actions = [
            NotificationService.checkPhoneAction,
            NotificationService.checkWalletAction,
            NotificationService.checkKeysAction,
            NotificationService.checkGlassesAction,
            NotificationService.snoozeAction
        ].map {
            UNNotificationAction(identifier: $0.identifier, title: $0.title)
        }

        let category = UNNotificationCategory(
            identifier: NotificationService.categoryIdentifier,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([category])
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleChecklistNotification(after delay: TimeInterval = 1.0) async {
        let content = UNMutableNotificationContent()
        content.title = "持ち物チェック"
        content.body = "け/さ/キ/め を確認してください"
        content.sound = .default
        content.categoryIdentifier = NotificationService.categoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 1.0), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            // noop: notification scheduling failures are non-fatal for app start
        }
    }
}
