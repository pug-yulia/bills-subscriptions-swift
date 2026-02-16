import Foundation
import SwiftData

@Model
final class AppSettings {
    @Attribute(.unique) var id: Int
    var preferredCurrencyCode: String

    init(id: Int = 1, preferredCurrencyCode: String = "USD") {
        self.id = id
        self.preferredCurrencyCode = preferredCurrencyCode
    }
}
