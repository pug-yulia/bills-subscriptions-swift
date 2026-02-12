import Foundation
import SwiftData

@Model
final class Category {
    @Attribute(.unique) var id: UUID

    var name: String
    var color: String?
    var icon: String?

    var createdAt: Date
    var updatedAt: Date

    // inverse связь (не обязателен, но удобно)
    @Relationship(deleteRule: .nullify, inverse: \PaymentEntry.category)
    var entries: [PaymentEntry] = []

    init(
        id: UUID = UUID(),
        name: String,
        color: String? = nil,
        icon: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
