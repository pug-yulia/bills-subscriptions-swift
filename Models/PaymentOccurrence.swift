import Foundation
import SwiftData

@Model
final class PaymentOccurrence {
    @Attribute(.unique) var id: UUID

    /// amount: number (в минимальных единицах, как в entry)
    var amountMinor: Int64

    /// paidAt: ISO string -> Date
    var paidAt: Date

    /// entryId: string -> связь на PaymentEntry
    var entry: PaymentEntry?

    init(
        id: UUID = UUID(),
        entry: PaymentEntry?,
        amountMinor: Int64,
        paidAt: Date
    ) {
        self.id = id
        self.entry = entry
        self.amountMinor = amountMinor
        self.paidAt = paidAt
    }
}
