import SwiftUI
import SwiftData

struct PaymentEntriesListView: View {
    let entries: [PaymentEntry]
    let iconProvider: (PaymentEntry) -> String
    let subtitleProvider: (PaymentEntry) -> String

    var onDelete: (PaymentEntry) -> Void
    var onEdit: (PaymentEntry) -> Void

    var swipeEnabled: Bool = true
    var dayAscending: Bool = true

    var sort: (PaymentEntry, PaymentEntry) -> Bool = {
        $0.dueDate < $1.dueDate
    }
    private let calendar = Calendar.current

    var body: some View {
        ForEach(groupedDays, id: \.day) { group in
            Section {
                ForEach(group.entries) { entry in
                    row(for: entry)
                }
            } header: {
                Text(dayTitle(group.day))
                    .textCase(nil) // чтобы не превращало в CAPS
            }
        }
    }

    // MARK: - Grouping

    private var groupedDays: [(day: Date, entries: [PaymentEntry])] {
        let sortedEntries = entries.sorted(by: sort)


        let dict = Dictionary(grouping: sortedEntries) { entry in
            calendar.startOfDay(for: entry.dueDate)
        }

        // сортируем дни по возрастанию
        let daysSorted = dict.keys.sorted(by: dayAscending ? (<) : (>))

        // внутри дня — тоже отсортируем по dueDate
        return daysSorted.map { day in
            let list = (dict[day] ?? []).sorted { $0.dueDate < $1.dueDate }
            return (day: day, entries: list)
        }
    }

    private func dayTitle(_ day: Date) -> String {
        // "26 февраля"
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_EN")
        fmt.dateFormat = "d MMMM"
        return fmt.string(from: day)
    }

    // MARK: - Row

    @ViewBuilder
    private func row(for entry: PaymentEntry) -> some View {
        let baseRow = PaymentEntryRowView(
            entry: entry,
            iconSystemName: iconProvider(entry),
            subtitle: subtitleProvider(entry)
        )

        if swipeEnabled {
            baseRow
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) { onDelete(entry) } label: {
                        Label("Delete", systemImage: "trash")
                    }

                    Button { onEdit(entry) } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
        } else {
            baseRow
        }
    }
}
