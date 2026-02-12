import Foundation
import SwiftData

enum DatabaseSeeder {

    static func seedIfNeeded(context: ModelContext) throws {
        // Проверяем: есть ли хотя бы одна категория (или PaymentEntry — как хочешь)
        let categoryCount = try context.fetchCount(FetchDescriptor<Category>())
        guard categoryCount == 0 else { return }

        let internet = Category(name: "Utilities", color: "#4D96FF", icon: "wifi")
        let home = Category(name: "Home", color: "#FF6B6B", icon: "house")
        let fun = Category(name: "Entertainment", color: "#6BCB77", icon: "tv")

        context.insert(internet)
        context.insert(home)
        context.insert(fun)

        context.insert(
            PaymentEntry(
                title: "Internet",
                amountMinor: 3999,
                currencyCode: "USD",
                type: .bill,
                category: internet,
                dueDate: Date()
            )
        )

        context.insert(
            PaymentEntry(
                title: "Electricity",
                amountMinor: 1245,
                currencyCode: "USD",
                type: .bill,
                category: home,
                dueDate: Date()
            )
        )

        context.insert(
            PaymentEntry(
                title: "Netflix",
                amountMinor: 1599,
                currencyCode: "USD",
                type: .subscription,
                category: fun,
                dueDate: Date()
            )
        )

        try context.save()
    }
}
