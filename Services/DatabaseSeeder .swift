import Foundation
import SwiftData

enum DatabaseSeeder {

    /// Обычный seed: только если база пустая
    static func seedIfNeeded(context: ModelContext) throws {
        let categoryCount = try context.fetchCount(FetchDescriptor<Category>())
        guard categoryCount == 0 else { return }
        try seedFresh(context: context)
    }

    /// Полный reset: удалить всё и создать заново (для кнопки в Settings)
    static func resetAndSeed(context: ModelContext) throws {
        // occurrences
        let occ = try context.fetch(FetchDescriptor<PaymentOccurrence>())
        occ.forEach { context.delete($0) }

        // entries
        let entries = try context.fetch(FetchDescriptor<PaymentEntry>())
        entries.forEach { context.delete($0) }

        // categories
        let cats = try context.fetch(FetchDescriptor<Category>())
        cats.forEach { context.delete($0) }

        try context.save()
        try seedFresh(context: context)
    }


    // MARK: - Private

    private static func seedFresh(context: ModelContext) throws {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Категории
        let utilities = Category(name: "Utilities", color: "#4D96FF", icon: "wifi")
        let home = Category(name: "Home", color: "#FF6B6B", icon: "house")
        let entertainment = Category(name: "Entertainment", color: "#6BCB77", icon: "tv")
        let food = Category(name: "Food", color: "#FFA41B", icon: "fork.knife")
        let transport = Category(name: "Transport", color: "#9B5DE5", icon: "car.fill")
        let health = Category(name: "Health", color: "#F15BB5", icon: "cross.case.fill")
        let education = Category(name: "Education", color: "#00BBF9", icon: "graduationcap.fill")
        let shopping = Category(name: "Shopping", color: "#00F5D4", icon: "bag.fill")

        let categories = [utilities, home, entertainment, food, transport, health, education, shopping]
        categories.forEach { context.insert($0) }

        // Bills (счета)
        let bills: [PaymentEntry] = [
            PaymentEntry(title: "Internet", amountMinor: 3999, currencyCode: "USD", type: .bill, category: utilities, dueDate: today),
            PaymentEntry(title: "Electricity", amountMinor: 1245, currencyCode: "USD", type: .bill, category: home, dueDate: cal.date(byAdding: .day, value: 3, to: today)!),
            PaymentEntry(title: "Water", amountMinor: 870, currencyCode: "USD", type: .bill, category: home, dueDate: cal.date(byAdding: .day, value: 10, to: today)!),
            PaymentEntry(title: "Mobile plan", amountMinor: 1299, currencyCode: "USD", type: .bill, category: utilities, dueDate: cal.date(byAdding: .day, value: 7, to: today)!),
            PaymentEntry(title: "Gas", amountMinor: 2150, currencyCode: "USD", type: .bill, category: home, dueDate: cal.date(byAdding: .day, value: 14, to: today)!),
            PaymentEntry(title: "Groceries", amountMinor: 5200, currencyCode: "EUR", type: .bill, category: food, dueDate: cal.date(byAdding: .day, value: 1, to: today)!),
            PaymentEntry(title: "Fuel", amountMinor: 4500, currencyCode: "EUR", type: .bill, category: transport, dueDate: cal.date(byAdding: .day, value: 5, to: today)!),
            PaymentEntry(title: "Pharmacy", amountMinor: 1590, currencyCode: "EUR", type: .bill, category: health, dueDate: cal.date(byAdding: .day, value: 2, to: today)!),
        ]

        bills.forEach { context.insert($0) }

        // Subscriptions (подписки) — частоты задаём repeatRule
        let subs: [PaymentEntry] = [
            PaymentEntry(title: "Netflix", amountMinor: 1599, currencyCode: "USD", type: .subscription, category: entertainment, dueDate: cal.date(byAdding: .day, value: 20, to: today)!, repeatRule: .monthly),
            PaymentEntry(title: "Spotify", amountMinor: 1099, currencyCode: "USD", type: .subscription, category: entertainment, dueDate: cal.date(byAdding: .day, value: 12, to: today)!, repeatRule: .monthly),
            PaymentEntry(title: "iCloud+", amountMinor: 299, currencyCode: "USD", type: .subscription, category: utilities, dueDate: cal.date(byAdding: .day, value: 9, to: today)!, repeatRule: .monthly),
            PaymentEntry(title: "Gym", amountMinor: 2500, currencyCode: "EUR", type: .subscription, category: health, dueDate: cal.date(byAdding: .day, value: 6, to: today)!, repeatRule: .monthly),
            PaymentEntry(title: "Language Course", amountMinor: 8900, currencyCode: "EUR", type: .subscription, category: education, dueDate: cal.date(byAdding: .day, value: 15, to: today)!, repeatRule: .monthly),
            PaymentEntry(title: "Weekly commute pass", amountMinor: 1200, currencyCode: "EUR", type: .subscription, category: transport, dueDate: cal.date(byAdding: .day, value: 7, to: today)!, repeatRule: .weekly),
            PaymentEntry(title: "Daily coffee", amountMinor: 350, currencyCode: "EUR", type: .subscription, category: food, dueDate: cal.date(byAdding: .day, value: 1, to: today)!, repeatRule: .daily),
            PaymentEntry(title: "Prime", amountMinor: 899, currencyCode: "USD", type: .subscription, category: shopping, dueDate: cal.date(byAdding: .day, value: 18, to: today)!, repeatRule: .yearly),
        ]

        subs.forEach { context.insert($0) }

        try context.save()
    }
}
