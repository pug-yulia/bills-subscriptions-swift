import Foundation
import SwiftData

@Model
final class Currency {
    @Attribute(.unique) var code: String   // "USD", "RUB"
    var name: String                       // "US Dollar"
    var symbol: String                     // "$"
    var minorUnit: Int                     // 2

    init(code: String, name: String, symbol: String, minorUnit: Int) {
        self.code = code
        self.name = name
        self.symbol = symbol
        self.minorUnit = minorUnit
    }
}
