import Foundation
import SwiftData

@Model
final class AppSettings {

    @Attribute(.unique)
    var id: UUID

    var preferredCurrencyCode: String

    init(preferredCurrencyCode: String = "USD") {
        self.id = UUID()
        self.preferredCurrencyCode = preferredCurrencyCode
    }
}
