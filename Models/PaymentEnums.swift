import Foundation

enum PaymentType: String, Codable, CaseIterable {
    case bill
    case subscription
}

enum RepeatRule: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly
    case yearly
}
