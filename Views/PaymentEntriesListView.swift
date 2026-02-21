import SwiftUI
import SwiftData

struct PaymentEntriesListView: View {
    let entries: [PaymentEntry]
    let iconProvider: (PaymentEntry) -> String
    let subtitleProvider: (PaymentEntry) -> String

    var onDelete: (PaymentEntry) -> Void
    var onEdit: (PaymentEntry) -> Void

    var body: some View {
        ForEach(entries) { entry in
            PaymentEntryRowView(
                entry: entry,
                iconSystemName: iconProvider(entry),
                subtitle: subtitleProvider(entry)
            )
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    onDelete(entry)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }

                Button {
                    onEdit(entry)
                } label: {
                    Label("Редактировать", systemImage: "pencil")
                }
                .tint(.blue)
            }
        }
    }
}