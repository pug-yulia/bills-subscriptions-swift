import Foundation
import SwiftData

@Model
final class PaymentEntry {

    @Attribute(.unique) var id: UUID

    var title: String

    /// сумма в минимальных единицах (копейки/центы)
    var amountMinor: Int64

    /// 🔥 вместо currencyCode: связь на Currency
    @Relationship var currency: Currency

    /// храним как String, чтобы SwiftData не капризничал
    var typeRaw: String
    var repeatRuleRaw: String?   // может быть nil

    /// ближайшая дата платежа
    var dueDate: Date

    var note: String?
    var isPaid: Bool

    var createdAt: Date
    var updatedAt: Date

    /// вместо categoryId: связь на Category (опционально)
    @Relationship var category: Category?

    /// inverse связь на факты оплат (PaymentOccurrence)
    @Relationship(deleteRule: .cascade, inverse: \PaymentOccurrence.entry)
    var occurrences: [PaymentOccurrence] = []

    // MARK: - Computed

    var type: PaymentType {
        get { PaymentType(rawValue: typeRaw) ?? .bill }
        set { typeRaw = newValue.rawValue }
    }

    var repeatRule: RepeatRule? {
        get { repeatRuleRaw.flatMap { RepeatRule(rawValue: $0) } }
        set { repeatRuleRaw = newValue?.rawValue }
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        title: String,
        amountMinor: Int64,
        currency: Currency,
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
        self.currency = currency
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
