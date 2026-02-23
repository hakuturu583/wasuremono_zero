import Foundation

enum CheckItem: String, CaseIterable, Hashable {
    case phone
    case wallet
    case keys
    case glasses

    var actionIdentifier: String {
        switch self {
        case .phone:
            return "CHECK_PHONE"
        case .wallet:
            return "CHECK_WALLET"
        case .keys:
            return "CHECK_KEYS"
        case .glasses:
            return "CHECK_GLASSES"
        }
    }

    var label: String {
        switch self {
        case .phone:
            return "け"
        case .wallet:
            return "さ"
        case .keys:
            return "キ"
        case .glasses:
            return "め"
        }
    }
}
