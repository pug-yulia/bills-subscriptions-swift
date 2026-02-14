import SwiftUI
import SwiftData

struct BillsScreen: View {

    enum FilterType: CaseIterable, Equatable {
        case all
        case thisMonth
        case next30Days

        var title: String {
            switch self {
            case .all: return "All"
            case .thisMonth: return "This Month"
            case .next30Days: return "Next 30 Days"
            }
        }
    }

    @Query(
        filter: #Predicate<PaymentEntry> { $0.typeRaw == "bill" },
        sort: \PaymentEntry.dueDate,
        order: .forward
    )
    private var bills: [PaymentEntry]

    @State private var selectedFilter: FilterType = .all

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                filterButtons

                if filteredBills.isEmpty {
                    Text("No bills found")
                        .foregroundStyle(.gray)
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 10) {
                        ForEach(filteredBills) { entry in
                            HomeRowItemView(
                                iconSystemName: "bolt.fill",
                                title: entry.title,
                                subtitle: entry.category?.name ?? "—",
                                rightText: formatMoneyMinor(
                                    entry.amountMinor,
                                    currencyCode: entry.currencyCode
                                )
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationTitle("Bills")
    }

    private var filterButtons: some View {
        HStack(spacing: 10) {
            ForEach(FilterType.allCases, id: \.self) { type in
                filterButton(title: type.title, type: type)
            }
        }
    }

    private func filterButton(title: String, type: FilterType) -> some View {
        Button {
            selectedFilter = type
        } label: {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    selectedFilter == type ? Color.blue : Color.gray.opacity(0.2)
                )
                .foregroundStyle(
                    selectedFilter == type ? .white : .primary
                )
                .clipShape(Capsule())
        }
    }

    private var filteredBills: [PaymentEntry] {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        // верхняя граница (исключающая) для next30Days
        let next30Exclusive = calendar.date(byAdding: .day, value: 30, to: today) ?? today

        switch selectedFilter {
        case .all:
            return bills

        case .thisMonth:
            return bills.filter {
                calendar.isDate($0.dueDate, equalTo: now, toGranularity: .month)
                && $0.dueDate >= today          // чтобы не показывать уже прошедшие счета этого месяца
            }

        case .next30Days:
            return bills.filter {
                let d = $0.dueDate
                return d >= today && d < next30Exclusive
            }
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
