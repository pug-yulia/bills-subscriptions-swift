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
//                    PaymentEntriesListView(
//                        entries: filteredSubs,
//                        emptyText: "No bills found",
//                        iconProvider: { entry in
//                            entry.category?.icon ?? "questionmark.circle"
//                           },
//                        subtitleProvider: { $0.category?.name ?? "—" }
//                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationTitle("Subscriptions")
    }

    private var filterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FrequencyFilter.allCases, id: \.self) { type in
                    PillButton(
                        title: type.rawValue,
                        isSelected: selectedFilter == type,
                        action: { selectedFilter = type }
                    )
                }
            }
        }
    }

    private var filteredSubs: [PaymentEntry] {
        // repeatRuleRaw optional, но у нас default = "monthly"
        Filtering.byOptional(
            subs,
            value: selectedFilter.rawRule,
            keyPath: \.repeatRuleRaw,
            defaultValue: "monthly"
        )
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
}
