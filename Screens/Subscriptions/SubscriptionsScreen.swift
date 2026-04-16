import SwiftUI
import SwiftData

struct SubscriptionsScreen: View {
    
    @Environment(\.modelContext) private var context
    
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
    @State private var entryToDelete: PaymentEntry?
    @State private var entryToEdit: PaymentEntry?

    var body: some View {
        List {
            
            // Фильтры other
            Section {
                filterButtons
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowSeparator(.hidden)
            }
            
            // Сами subs
            Section {
                if filteredSubs.isEmpty {
                    Text("No subscriptions found")
                        .foregroundStyle(.gray)
                        .listRowSeparator(.hidden)
                } else {
                    PaymentEntriesListView(
                        entries: filteredSubs,
                        iconProvider: { $0.category?.icon ?? "questionmark.circle" },
                        subtitleProvider: {  ruleTitle($0.repeatRuleRaw ?? "monthly") },
                        onDelete: { entryToDelete = $0 },
                        onEdit: { entryToEdit = $0 }
                    )
                }
            }
            
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle("Subscriptions")     
        .alert("Delete payment?", isPresented: Binding(
            get: { entryToDelete != nil },
            set: { if !$0 { entryToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let e = entryToDelete { deleteEntry(e) }
                entryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                entryToDelete = nil
            }
        }
        .sheet(item: $entryToEdit) { e in
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
