import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \PaymentEntry.dueDate, order: .reverse)
    private var payments: [PaymentEntry]

    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if payments.isEmpty {
                    Text("Нет платежей")
                        .foregroundStyle(.gray)
                } else {
                    List {
                        ForEach(payments) { item in
                            PaymentRow(entry: item)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Payments")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showResetConfirm = true
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            .alert("Сбросить базу данных?", isPresented: $showResetConfirm) {
                Button("Сбросить", role: .destructive) {
                    resetDatabase()
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Все платежи и категории будут удалены и созданы заново.")
            }
        }
        .task {
            do {
                try DatabaseSeeder.seedIfNeeded(context: context)
            } catch {
                print("Seed error:", error)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            context.delete(payments[idx])
        }
        try? context.save()
    }

    private func resetDatabase() {
        do {
            try context.delete(model: PaymentOccurrence.self)
            try context.delete(model: PaymentEntry.self)
            try context.delete(model: Category.self)

            try context.save()

            try DatabaseSeeder.seedIfNeeded(context: context)
        } catch {
            print("Reset DB error:", error)
        }
    }
}
struct PaymentRow: View {
    let entry: PaymentEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.title)
                    .font(.headline)

                Text(entry.typeRaw == "subscription" ? "Subscription" : "Bill")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            let amount = Double(entry.amountMinor) / 100.0
            Text("\(entry.currencyCode) \(amount, specifier: "%.2f")")
                .fontWeight(.bold)
        }
        .padding(.vertical, 6)
    }
}
