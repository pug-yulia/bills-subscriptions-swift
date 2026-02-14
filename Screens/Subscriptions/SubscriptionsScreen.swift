import SwiftUI
import SwiftData

struct SubscriptionsScreen: View {

    enum FrequencyFilter: String, CaseIterable, Equatable {
        case all = "All"
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"

        var rawRule: String? {
            switch self {
            case .all: return nil
            case .daily: return "daily"
            case .weekly: return "weekly"
            case .monthly: return "monthly"
            case .yearly: return "yearly"
            }
        }
    }

    @Query(
        filter: #Predicate<PaymentEntry> { $0.typeRaw == "subscription" },
        sort: \PaymentEntry.dueDate,
        order: .forward
    )
    private var subs: [PaymentEntry]

    @State private var selectedFilter: FrequencyFilter = .all

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                filterButtons

                if filteredSubs.isEmpty {
                    Text("No subscriptions yet")
                        .foregroundStyle(.gray)
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 10) {
                        ForEach(filteredSubs) { entry in
                            let rule = (entry.repeatRuleRaw ?? "monthly")

                            HomeRowItemView(
                                iconSystemName: "repeat",
                                title: entry.title,
                                subtitle: ruleTitle(rule),
                                rightText: "\(formatMoneyMinor(entry.amountMinor, currencyCode: entry.currencyCode)) /\(ruleSuffix(rule))"
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationTitle("Subscriptions")
    }

    private var filterButtons: some View {
        HStack(spacing: 10) {
            ForEach(FrequencyFilter.allCases, id: \.self) { type in
                filterButton(title: type.rawValue, type: type)
            }
        }
    }

    private func filterButton(title: String, type: FrequencyFilter) -> some View {
        Button {
            selectedFilter = type
        } label: {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(selectedFilter == type ? Color.blue : Color.gray.opacity(0.2))
                .foregroundStyle(selectedFilter == type ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    private var filteredSubs: [PaymentEntry] {
        guard let rule = selectedFilter.rawRule else {
            return subs
        }
        return subs.filter { ($0.repeatRuleRaw ?? "monthly") == rule }
    }

    private func ruleTitle(_ raw: String) -> String {
        switch raw {
        case "daily": return "daily"
        case "weekly": return "weekly"
        case "yearly": return "yearly"
        default: return "monthly"
        }
    }

    private func ruleSuffix(_ raw: String) -> String {
        switch raw {
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
