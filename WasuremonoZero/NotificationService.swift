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
        let actions = CheckItem.allCases.map {
            UNNotificationAction(identifier: $0.actionIdentifier, title: $0.label)
        } + [
            UNNotificationAction(
                identifier: NotificationService.snoozeAction.identifier,
                title: NotificationService.snoozeAction.title
            )
        ]

        return UNNotificationCategory(
            identifier: NotificationService.categoryIdentifier,
            actions: actions,
            intentIdentifiers: [],
            options: []
        )
    }

    func scheduleCheckNotification(enabledItems: Set<CheckItem>) async {
        guard enabledItems.isEmpty == false else {
            return
        }

        let labels = CheckItem.allCases
            .filter { enabledItems.contains($0) }
            .map(\.label)
            .joined(separator: " / ")

        let content = UNMutableNotificationContent()
        content.title = "持ち物チェック"
        content.body = "\(labels) を確認してください"
        content.sound = .default
        content.categoryIdentifier = NotificationService.categoryIdentifier

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            return
        }
    }
}
