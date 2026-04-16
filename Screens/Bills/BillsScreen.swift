import SwiftUI
import SwiftData

struct BillsScreen: View {
    @Environment(\.modelContext) private var context
    // MARK: - Category filter

    enum CategoryFilter: Equatable {
        case all
        case uncategorized
        case category(UUID)
    }

    // MARK: - Date filter

    enum DateFilter: CaseIterable, Equatable {
        case all
        case overdue
        case today
        case tomorrow
        case thisWeek
        case nextWeek
        case thisMonth
        case nextMonth
        case next30Days
        case next90Days

        var title: String {
            switch self {
            case .all: return "All"
            case .overdue: return "Overdue"
            case .today: return "Today"
            case .tomorrow: return "Tomorrow"
            case .thisWeek: return "This Week"
            case .nextWeek: return "Next Week"
            case .thisMonth: return "This Month"
            case .nextMonth: return "Next Month"
            case .next30Days: return "Next 30"
            case .next90Days: return "Next 90"
            }
        }
    }

    // Bills only
    @Query(
        filter: #Predicate<PaymentEntry> { $0.typeRaw == "bill" },
        sort: \PaymentEntry.dueDate,
        order: .forward
    )
    private var bills: [PaymentEntry]
    // Categories for filter bar
    @Query(sort: \Category.name, order: .forward)
    private var categories: [Category]

    @State private var selectedCategory: CategoryFilter = .all
    @State private var selectedDate: DateFilter = .all
    @State private var entryToDelete: PaymentEntry?
    @State private var entryToEdit: PaymentEntry?
    @State private var sortAscending: Bool = true
    
    var body: some View {
        List {
            // Фильтры как строки списка (чтобы List оставался основным контейнером и swipe работал)
            Section {
                categoryFilterBar
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 6, trailing: 0))
                    .listRowSeparator(.hidden)

                dateFilterBar
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                    .listRowSeparator(.hidden)
            }

            // Сами счета
            Section {
                if filteredBills.isEmpty {
                    Text("No bills found")
                        .foregroundStyle(.gray)
                        .listRowSeparator(.hidden)
                } else {
                    PaymentEntriesListView(
                        entries: filteredBills,
                        iconProvider: { $0.category?.icon ?? "questionmark.circle" },
                        subtitleProvider: { $0.category?.name ?? "—" },
                        onDelete: { entryToDelete = $0 },
                        onEdit: { entryToEdit = $0 },
                        dayAscending: sortAscending
                    )
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle("Bills")
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button {
            sortAscending.toggle()
        } label: {
            Image(systemName: "arrow.up")
                .rotationEffect(.degrees(sortAscending ? 0 : 180))
        }
        .accessibilityLabel(sortAscending ? "Sort: oldest first" : "Sort: newest first")
    }
}
        .alert("Delete payment?", isPresented: Binding(
            get: { entryToDelete != nil },
            set: { if !$0 { entryToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let e = entryToDelete {
                    deleteEntry(e)
                }
                entryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                entryToDelete = nil
            }
        }
        .sheet(item: $entryToEdit, onDismiss: {
        entryToEdit = nil
        }) { e in
            PaymentFormScreen(mode: .edit(e))
        }

        
    }
    
    private func deleteEntry(_ entry: PaymentEntry) {
           context.delete(entry)
           do {
               try context.save()
           } catch {
               print("Failed to delete entry: \(error)")
           }
       }


    // MARK: - Bars

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {

                PillButton(title: "All", isSelected: selectedCategory == .all) {
                    selectedCategory = .all
                }

                PillButton(title: "No category", isSelected: selectedCategory == .uncategorized) {
                    selectedCategory = .uncategorized
                }

                ForEach(categories) { c in
                    PillButton(
                        title: c.name,
                        isSelected: selectedCategory == .category(c.id)
                    ) {
                        selectedCategory = .category(c.id)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var dateFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(DateFilter.allCases, id: \.self) { d in
                    PillButton(title: d.title, isSelected: selectedDate == d) {
                        selectedDate = d
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Filtering

private var filteredBills: [PaymentEntry] {
    let afterCategory = filterByCategory(bills)
    let afterDate = filterByDate(afterCategory)

    return afterDate.sorted {
        sortAscending ? ($0.dueDate < $1.dueDate) : ($0.dueDate > $1.dueDate)
    }
}

    private func filterByCategory(_ source: [PaymentEntry]) -> [PaymentEntry] {
        switch selectedCategory {
        case .all:
            return source
        case .uncategorized:
            return source.filter { $0.category == nil }
        case .category(let id):
            return source.filter { $0.category?.id == id }
        }
    }

    private func filterByDate(_ source: [PaymentEntry]) -> [PaymentEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        func inRange(_ d: Date, _ start: Date, _ endExclusive: Date) -> Bool {
            d >= start && d < endExclusive
        }

        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today) ?? tomorrow

        let next30 = calendar.date(byAdding: .day, value: 30, to: today) ?? today
        let next90 = calendar.date(byAdding: .day, value: 90, to: today) ?? today

        let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: thisWeekStart) ?? thisWeekStart
        let nextWeekEnd = calendar.date(byAdding: .weekOfYear, value: 2, to: thisWeekStart) ?? nextWeekStart

        let thisMonthStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: thisMonthStart) ?? thisMonthStart
        let nextMonthEnd = calendar.date(byAdding: .month, value: 2, to: thisMonthStart) ?? nextMonthStart

        switch selectedDate {
        case .all:
            return source
        case .overdue:
            return source.filter { $0.dueDate < today }
        case .today:
            return source.filter { calendar.isDate($0.dueDate, inSameDayAs: today) }
        case .tomorrow:
            return source.filter { inRange($0.dueDate, tomorrow, dayAfterTomorrow) }
        case .thisWeek:
            return source.filter { inRange($0.dueDate, today, nextWeekStart) }
        case .nextWeek:
            return source.filter { inRange($0.dueDate, nextWeekStart, nextWeekEnd) }
        case .thisMonth:
            return source.filter { inRange($0.dueDate, today, nextMonthStart) }
        case .nextMonth:
            return source.filter { inRange($0.dueDate, nextMonthStart, nextMonthEnd) }
        case .next30Days:
            return source.filter { inRange($0.dueDate, today, next30) }
        case .next90Days:
            return source.filter { inRange($0.dueDate, today, next90) }
        }
    }
}
