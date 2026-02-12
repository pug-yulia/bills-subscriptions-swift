import SwiftUI
import SwiftData

struct BillsScreen: View {
    @Query(filter: #Predicate<PaymentEntry> { $0.typeRaw == "bill" },
           sort: \PaymentEntry.dueDate, order: .reverse)
    private var bills: [PaymentEntry]

    var body: some View {
        NavigationStack {
            List(bills) { entry in
                Text(entry.title)
            }
            .navigationTitle("Bills")
        }
    }
}
