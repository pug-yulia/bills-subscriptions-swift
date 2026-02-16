import SwiftUI

struct AddPaymentScreen: View {
    
    enum PaymentType: String, CaseIterable {
        case bill = "Bill"
        case subscription = "Subscription"
    }
    
    enum RepeatRule: String, CaseIterable {
        case daily, weekly, monthly, yearly
    }
    
    @State private var type: PaymentType = .bill
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var dueDate: Date = Date()
    @State private var showDatePicker = false
    @State private var repeatRule: RepeatRule = .monthly
    @State private var note: String = ""
    @State private var selectedCurrency: String? = nil
    @State private var selectedCategory: String? = nil
    
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    typeSection
                    textField("Name", text: $title)
                    textField("Amount", text: $amount, keyboard: .decimalPad)
                    
                    detailsSection
                    dateSection
                    
                    if type == .subscription {
                        repeatSection
                    }
                    
                    noteSection
                    saveButton
                }
                .padding(16)
            }
            .navigationTitle("Add New Payment")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }

        }
    }
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type").font(.headline)
            
            HStack(spacing: 10) {
                ForEach(PaymentType.allCases, id: \.self) { t in
                    Button {
                        type = t
                    } label: {
                        Text(t.rawValue)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(type == t ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundStyle(type == t ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details").font(.headline)
            
            VStack(spacing: 12) {

                HStack {
                    Text("Currency")
                    Spacer()
                    Text(selectedCurrency ?? "Not set")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Category")
                    Spacer()
                    Text(selectedCategory ?? "Not set")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date").font(.headline)
            
            Button {
                showDatePicker.toggle()
            } label: {
                HStack {
                    Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "calendar")
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4))
                )
            }
            
            if showDatePicker {
                DatePicker("", selection: $dueDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
        }
    }
    
    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repeat").font(.headline)
            
            HStack(spacing: 10) {
                ForEach(RepeatRule.allCases, id: \.self) { r in
                    Button {
                        repeatRule = r
                    } label: {
                        Text(r.rawValue)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(repeatRule == r ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundStyle(repeatRule == r ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note").font(.headline)
            
            TextEditor(text: $note)
                .frame(height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4))
                )
        }
    }
    
    private var saveButton: some View {
        Button { } label: {
            Text("Save")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 8)
    }
    
    private func textField(
        _ title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            
            TextField("", text: text)
                .keyboardType(keyboard)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4))
                )
        }
    }
}

