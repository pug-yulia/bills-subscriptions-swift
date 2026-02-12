import SwiftData
import SwiftUI

struct HomeScreen: View {

    @Query(sort: \PaymentEntry.dueDate, order: .forward)
    private var entries: [PaymentEntry]

    private var totalThisMonthMinor: Int64 {
        let now = Date()
        let cal = Calendar.current
        return
            entries
            .filter {
                cal.isDate($0.dueDate, equalTo: now, toGranularity: .month)
            }
            .reduce(0) { $0 + $1.amountMinor }
    }

    private var upcomingBills: [PaymentEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return
            entries
            .filter { $0.typeRaw == "bill" && $0.dueDate >= today }
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(4)
            .map { $0 }
    }

    private var activeSubscriptions: [PaymentEntry] {
        entries
            .filter { $0.typeRaw == "subscription" }
            .sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title)
                    == .orderedAscending
            }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                HomeHeaderView(
                    greeting: "Good \(timeOfDay()),",
                    totalThisMonthText: formatMoneyMinor(
                        totalThisMonthMinor,
                        currencyCode: "USD"
                    ),
                    upcomingBillsText: formatMoneyMinor(
                        totalThisMonthMinor,
                        currencyCode: "USD"
                    )  // как в RN-версии (пока одинаково)
                )

                VStack(alignment: .leading, spacing: 18) {

                    // Upcoming Bills
                    HomeSectionHeaderView(
                        title: "Upcoming Bills",
                        onSeeAll: {
                            // TODO: навигация в Bills tab (сделаем позже)
                        }
                    )

                    if upcomingBills.isEmpty {
                        Text("Нет ближайших счетов")
                            .foregroundStyle(.gray)
                            .padding(.vertical, 6)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(upcomingBills) { item in
                                HomeRowItemView(
                                    iconSystemName: "bolt.fill",
                                    title: item.title,
                                    subtitle: item.category?.name ?? "—",
                                    rightText: formatMoneyMinor(
                                        item.amountMinor,
                                        currencyCode: item.currencyCode
                                    )
                                )
                            }
                        }
                    }

                    // Active Subscriptions
                    HomeSectionHeaderView(
                        title: "Active Subscriptions",
                        onSeeAll: {
                            // TODO: навигация в Subscriptions tab (сделаем позже)
                        }
                    )

                    if activeSubscriptions.isEmpty {
                        Text("Нет подписок")
                            .foregroundStyle(.gray)
                            .padding(.vertical, 6)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(activeSubscriptions) { item in
                                let rule = (item.repeatRuleRaw ?? "monthly")
                                HomeRowItemView(
                                    iconSystemName: "square.grid.2x2.fill",
                                    title: item.title,
                                    subtitle: rule,
                                    rightText:
                                        "\(formatMoneyMinor(item.amountMinor, currencyCode: item.currencyCode)) /\(ruleToUnit(rule))"
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
        }
        .background(Color.white)
    }

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

    private func formatMoneyMinor(_ amountMinor: Int64, currencyCode: String)
        -> String
    {
        // Пока без таблицы валют/курсов (как в RN). Если надо — добавим Currency/FxRate модели позже.
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
