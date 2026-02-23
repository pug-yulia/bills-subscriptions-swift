import SwiftData
import SwiftUI

struct HomeScreen: View {
    @Binding var selectedTab: Tab
    
    // Данные
    @Query(sort: \PaymentEntry.dueDate, order: .forward)
    private var entries: [PaymentEntry]
    
    // Настройки + валюты + курсы
    @Query private var settings: [AppSettings]
    @Query(sort: \Currency.code, order: .forward) private var currencies: [Currency]
    @Query private var rates: [ExchangeRate]
    
    // MARK: - Derived lists
    
    private var upcomingBills: [PaymentEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { $0.typeRaw == "bill" && $0.dueDate >= today }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(4)
            .map { $0 }
    }
    
    private var activeSubscriptions: [PaymentEntry] {
        entries
            .filter { $0.typeRaw == "subscription" }
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            .prefix(3)
            .map { $0 }
    }
    
    // MARK: - Money (converted)
    
    private var preferredCurrencyCode: String {
        settings.first?.preferredCurrencyCode ?? "USD"
    }
    
    private var preferredCurrency: Currency? {
        currencies.first(where: { $0.code == preferredCurrencyCode })
    }
    
    private var totalThisMonthMinorConverted: Int64 {
        let now = Date()
        let cal = Calendar.current
        
        let monthEntries = entries.filter {
            cal.isDate($0.dueDate, equalTo: now, toGranularity: .month)
        }
        
        return sumConvertedMinor(monthEntries)
    }
    
    private var upcomingBillsMinorConverted: Int64 {
        sumConvertedMinor(upcomingBills)
    }
    
    private func sumConvertedMinor(_ list: [PaymentEntry]) -> Int64 {
        // Если целевая валюта не найдена (например, валюты ещё не сидились) —
        // показываем "как есть" (сумма minor без смешивания валют — упростим, как fallback).
        guard let to = preferredCurrency else {
            return list.reduce(0) { $0 + $1.amountMinor }
        }
        
        return list.reduce(Int64(0)) { acc, e in
            let from = e.currency
            let converted = Money.convertMinor(
                amountMinor: e.amountMinor,
                from: from,
                to: to,
                rates: rates
            )
            return acc + converted
        }
    }
    
    // MARK: - UI
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                
                HomeHeaderView(
                    greeting: "Good \(timeOfDay()),",
                    totalThisMonthText: headerTotalText(),
                    upcomingBillsText: headerUpcomingText()
                )
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    // Upcoming Bills
                    HomeSectionHeaderView(
                        title: "Upcoming Bills",
                        onSeeAll: { selectedTab = .bills }
                    )
                    
                    if upcomingBills.isEmpty {
                        Text("Нет ближайших счетов")
                            .foregroundStyle(.gray)
                            .padding(.vertical, 6)
                    } else {
                        
                        PaymentEntriesListView(
                            entries: upcomingBills,
                            iconProvider: { $0.category?.icon ?? "questionmark.circle" },
                            subtitleProvider: { $0.category?.name ?? "—" },
                            onDelete: { _ in },   //?
                            onEdit: { _ in }   //?
                        )
                        //                        PaymentEntriesListView(
                        //                            entries: upcomingBills,
                        //                            emptyText: "No bills found",
                        //                            iconProvider: { entry in
                        //                                entry.category?.icon ?? "questionmark.circle"
                        //                               },
                        //                            subtitleProvider: { $0.category?.name ?? "—" }
                        //                        )
                        
                        
                    }
                    
                    // Active Subscriptions
                    HomeSectionHeaderView(
                        title: "Active Subscriptions",
                        onSeeAll: { selectedTab = .subscriptions }
                    )
                    
                    if activeSubscriptions.isEmpty {
                        Text("Нет подписок")
                            .foregroundStyle(.gray)
                            .padding(.vertical, 6)
                    } else {
                        
                        PaymentEntriesListView(
                            entries: activeSubscriptions,
                            iconProvider: { $0.category?.icon ?? "questionmark.circle" },
                            subtitleProvider: { ruleToUnit($0.repeatRuleRaw ?? "monthly") },
                            onDelete: { _ in },   //?
                            onEdit: { _ in }   //?
                        )
                        //                        PaymentEntriesListView(
                        //                            entries: activeSubscriptions,
                        //                            emptyText: "No bills found",
                        //                            iconProvider: { entry in
                        //                                   entry.category?.icon ?? "questionmark.circle"
                        //                               },
                        //                            subtitleProvider: { $0.category?.name ?? "—" }
                        //                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .background(Color.white)
    }
    
    // MARK: - Header formatting
    
    private func headerTotalText() -> String {
        if let to = preferredCurrency {
            return Money.formatMinor(totalThisMonthMinorConverted, currency: to)
        }
        // fallback, если валюты не загружены
        return formatMoneyMinor(totalThisMonthMinorConverted, currencyCode: preferredCurrencyCode)
    }
    
    private func headerUpcomingText() -> String {
        if let to = preferredCurrency {
            return Money.formatMinor(upcomingBillsMinorConverted, currency: to)
        }
        return formatMoneyMinor(upcomingBillsMinorConverted, currencyCode: preferredCurrencyCode)
    }
    
    // MARK: - Helpers (оставил твои)
    
    private func timeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "morning ☀️" }
        if hour < 18 { return "afternoon 🌤️" }
        return "evening 🌙"
    }
    
    private func ruleToUnit(_ rule: String) -> String {
        switch rule {
        case "daily": return "day"
        case "weekly": return "week"
        case "yearly": return "year"
        default: return "month"
        }
    }
    
    private func formatMoneyMinor(_ amountMinor: Int64, currencyCode: String) -> String {
        let symbol: String = {
            switch currencyCode {
            case "USD": return "$"
            case "RUB": return "₽"
            case "EUR": return "€"
            default: return currencyCode + " "
            }
        }()
        
        let value = Double(amountMinor) / 100.0
        return "\(symbol)\(String(format: "%.2f", value))"
    }
}
