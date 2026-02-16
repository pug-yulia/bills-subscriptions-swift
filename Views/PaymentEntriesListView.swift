import SwiftUI
import SwiftData

struct PaymentEntriesListView: View {
    @Environment(\.modelContext) private var context

    let entries: [PaymentEntry]
    let emptyText: String
    let iconProvider: (PaymentEntry) -> String
    let subtitleProvider: (PaymentEntry) -> String

    // Если нужно удаление — включаем флагом
    var allowDelete: Bool = false

    var body: some View {
        if entries.isEmpty {
            Text(emptyText)
                .foregroundStyle(.gray)
                .padding(.top, 40)
        } else {
            // Можно оставить VStack, а можно List. Для одинакового вида с Home — VStack.
            VStack(spacing: 10) {
                ForEach(entries) { entry in
                    HomeRowItemView(
                        iconSystemName: iconProvider(entry),
                        title: entry.title,
                        subtitle: subtitleProvider(entry),
                        rightText: Money.formatMinor(entry.amountMinor, currency: entry.currency)
                    )
                }
            }
        }
    }
}
