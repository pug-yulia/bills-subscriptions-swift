import Foundation
import SwiftData

@Model
final class ExchangeRate {
    @Attribute(.unique) var id: String // "\(from)->\(to)" чтобы уникальность была простой

    var fromCode: String
    var toCode: String
    var rate: Double        // 1 from = rate to
    var updatedAt: Date

    init(fromCode: String, toCode: String, rate: Double, updatedAt: Date = Date()) {
        self.fromCode = fromCode
        self.toCode = toCode
        self.rate = rate
        self.updatedAt = updatedAt
        self.id = "\(fromCode)->\(toCode)"
    }
}
