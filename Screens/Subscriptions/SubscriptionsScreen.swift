import SwiftUI
import SwiftData

struct SubscriptionsScreen: View {
    @Query(filter: #Predicate<PaymentEntry> { $0.typeRaw == "subscription" },
           sort: \PaymentEntry.dueDate, order: .reverse)
    private var subs: [PaymentEntry]

    var body: some View {
        NavigationStack {
            List(subs) { entry in
                Text(entry.title)
            }
            .navigationTitle("Subscriptions")
        }
    }
}
