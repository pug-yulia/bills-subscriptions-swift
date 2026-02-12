import Foundation
import SwiftData

@Model
final class PaymentEntry {
    @Attribute(.unique) var id: UUID

    var title: String

    /// сумма в минимальных единицах (копейки/центы) — как в TS
    var amountMinor: Int64

    /// "USD", "RUB" и т.д.
    var currencyCode: String

    /// храним как String, чтобы SwiftData не капризничал
    var typeRaw: String
    var repeatRuleRaw: String?   // может быть nil / null

    /// ближайшая дата платежа (dueDate ISO -> Date)
    var dueDate: Date

    var note: String?
    var isPaid: Bool

    var createdAt: Date
    var updatedAt: Date

    /// вместо categoryId: связь на Category
    var category: Category?

    /// inverse связь на факты оплат (PaymentOccurence)
    @Relationship(deleteRule: .cascade, inverse: \PaymentOccurrence.entry)
    var occurrences: [PaymentOccurrence] = []

    var type: PaymentType {
        get { PaymentType(rawValue: typeRaw) ?? .bill }
        set { typeRaw = newValue.rawValue }
    }

    var repeatRule: RepeatRule? {
        get {
            guard let repeatRuleRaw else { return nil }
            return RepeatRule(rawValue: repeatRuleRaw)
        }
        set {
            repeatRuleRaw = newValue?.rawValue
        }
    }

    init(
        id: UUID = UUID(),
        title: String,
        amountMinor: Int64,
        currencyCode: String,
        type: PaymentType,
        category: Category?,
        dueDate: Date,
        repeatRule: RepeatRule? = nil,
        note: String? = nil,
        isPaid: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amountMinor = amountMinor
        self.currencyCode = currencyCode
        self.typeRaw = type.rawValue
        self.category = category
        self.dueDate = dueDate
        self.repeatRuleRaw = repeatRule?.rawValue
        self.note = note
        self.isPaid = isPaid
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
