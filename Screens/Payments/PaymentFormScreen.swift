import SwiftUI
import SwiftData

struct PaymentFormScreen: View {

    enum Mode: Equatable {
        case create(defaultType: PaymentType = .bill)
        case edit(PaymentEntry)
    }

    // MARK: - Dependencies

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var settings: [AppSettings]
    @Query(sort: \Currency.code, order: .forward) private var currencies: [Currency]
    @Query(sort: \Category.name, order: .forward) private var categories: [Category]

    // MARK: - Input

    private let mode: Mode

    // MARK: - Form state

    @State private var type: PaymentType
    @State private var title: String
    @State private var amount: String
    @State private var dueDate: Date
    @State private var showDatePicker: Bool
    @State private var repeatRule: RepeatRule
    @State private var note: String

    @State private var selectedCurrency: Currency?
    @State private var selectedCategory: Category?

    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    // MARK: - Init (важно: предзаполнение для edit делаем тут)

    init(mode: Mode) {
        self.mode = mode

        switch mode {
        case .create(let defaultType):
            _type = State(initialValue: defaultType)
            _title = State(initialValue: "")
            _amount = State(initialValue: "")
            _dueDate = State(initialValue: Date())
            _showDatePicker = State(initialValue: false)
            _repeatRule = State(initialValue: .monthly)
            _note = State(initialValue: "")
            _selectedCurrency = State(initialValue: nil)
            _selectedCategory = State(initialValue: nil)

        case .edit(let entry):
            _type = State(initialValue: entry.type)
            _title = State(initialValue: entry.title)
            _amount = State(initialValue: PaymentFormScreen.formatMinorToUserString(
                entry.amountMinor,
                minorUnit: entry.currency.minorUnit
            ))
            _dueDate = State(initialValue: entry.dueDate)
            _showDatePicker = State(initialValue: false)
            _repeatRule = State(initialValue: entry.repeatRule ?? .monthly)
            _note = State(initialValue: entry.note ?? "")
            _selectedCurrency = State(initialValue: entry.currency)
            _selectedCategory = State(initialValue: entry.category)
        }
    }

    // MARK: - UI

    var body: some View {
        NavigationStack {
            ZStack {

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

                // MARK: Floating Calendar Overlay (no first-open resize jump)

Color.black
    .opacity(showDatePicker ? 0.4 : 0)
    .ignoresSafeArea()
    .animation(.easeInOut(duration: 0.18), value: showDatePicker)
    .onTapGesture {
        withAnimation(.easeInOut(duration: 0.18)) {
            showDatePicker = false
        }
    }
    .allowsHitTesting(showDatePicker)

VStack(spacing: 16) {

    DatePicker(
        "Select Date",
        selection: $dueDate,
        displayedComponents: .date
    )
    .datePickerStyle(.graphical)
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
    )
    .shadow(radius: 20)
    // фиксируем ширину, чтобы не было перепрыгиваний из-за измерения контента
    .frame(maxWidth: 420)
    .padding(.horizontal, 16)

    Button {
        withAnimation(.easeInOut(duration: 0.18)) {
            showDatePicker = false
        }
    } label: {
        Text("Close")
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 28)
            .background(Color.blue)
            .clipShape(Capsule())
    }
}
.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
.opacity(showDatePicker ? 1 : 0)
.scaleEffect(showDatePicker ? 1 : 0.98, anchor: .center)
.animation(.spring(response: 0.28, dampingFraction: 0.9), value: showDatePicker)
.allowsHitTesting(showDatePicker)
.zIndex(10)
            }
            .navigationTitle(screenTitle)
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
            .onAppear {
                applyCreateDefaultsIfNeeded()
            }
            .alert("Ошибка", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }

    private var screenTitle: String {
        switch mode {
        case .create: return "Add Payment"
        case .edit: return "Edit Payment"
        }
    }

    // MARK: - Sections

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type").font(.headline)

            HStack(spacing: 10) {
                ForEach(PaymentType.allCases, id: \.self) { t in
                    Button {
                        type = t
                    } label: {
                        Text(t == .bill ? "Bill" : "Subscription")
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
                    Picker("", selection: Binding(
                        get: { selectedCurrency?.code ?? "" },
                        set: { newCode in
                            selectedCurrency = currencies.first(where: { $0.code == newCode })
                        }
                    )) {
                        Text("Not set").tag("")
                        ForEach(currencies, id: \.code) { cur in
                            Text("\(cur.code) (\(cur.symbol))").tag(cur.code)
                        }
                    }
                    .labelsHidden()
                }

                HStack {
                    Text("Category")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { selectedCategory?.id.uuidString ?? "" },
                        set: { newIdStr in
                            selectedCategory = categories.first(where: { $0.id.uuidString == newIdStr })
                        }
                    )) {
                        Text("Not set").tag("")
                        ForEach(categories) { c in
                            Text(c.name).tag(c.id.uuidString)
                        }
                    }
                    .labelsHidden()
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
                withAnimation {
                    showDatePicker = true
                }
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
                        Text(r.rawValue.capitalized)
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
        Button {
            save()
        } label: {
            Text(saveButtonTitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 8)
    }

    private var saveButtonTitle: String {
        switch mode {
        case .create: return "Save"
        case .edit: return "Save Changes"
        }
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

    // MARK: - Defaults (create)

    private func applyCreateDefaultsIfNeeded() {
        guard case .create = mode else { return }
        guard selectedCurrency == nil else { return }

        // 1) preferredCurrencyCode из настроек
        if let code = settings.first?.preferredCurrencyCode,
           let cur = currencies.first(where: { $0.code == code }) {
            selectedCurrency = cur
            return
        }

        // 2) иначе — первая доступная
        selectedCurrency = currencies.first
    }

    // MARK: - Save

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            fail("Введите название (Name).")
            return
        }

        guard let currency = selectedCurrency else {
            fail("Выберите валюту (Currency).")
            return
        }

        guard let amountMinor = Self.parseUserAmountToMinor(amount, minorUnit: currency.minorUnit) else {
            fail("Введите корректную сумму (Amount).")
            return
        }

        let noteValue = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote: String? = noteValue.isEmpty ? nil : noteValue

        do {
            switch mode {
            case .create:
                let entry = PaymentEntry(
                    title: trimmedTitle,
                    amountMinor: amountMinor,
                    currency: currency,
                    type: type,
                    category: selectedCategory,
                    dueDate: dueDate,
                    repeatRule: (type == .subscription ? repeatRule : nil),
                    note: finalNote
                )
                context.insert(entry)
                try context.save()
                dismiss()

            case .edit(let entry):
                entry.title = trimmedTitle
                entry.amountMinor = amountMinor
                entry.currency = currency
                entry.type = type
                entry.category = selectedCategory
                entry.dueDate = dueDate
                entry.repeatRule = (type == .subscription ? repeatRule : nil)
                entry.note = finalNote
                entry.updatedAt = Date()

                try context.save()
                dismiss()
            }
        } catch {
            fail("Не удалось сохранить: \(error.localizedDescription)")
        }
    }

    private func fail(_ message: String) {
        validationMessage = message
        showValidationAlert = true
    }

    // MARK: - Amount helpers

    private static func parseUserAmountToMinor(_ text: String, minorUnit: Int) -> Int64? {
        // поддержим и "12.34" и "12,34"
        let cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")

        guard !cleaned.isEmpty else { return nil }
        guard let dec = Decimal(string: cleaned) else { return nil }

        var scaled = dec
        for _ in 0..<max(0, minorUnit) {
            scaled *= 10
        }

        // Округляем до целого вниз/к ближайшему — выберем "банковский" .plain
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .plain)

        return (rounded as NSDecimalNumber).int64Value
    }

    private static func formatMinorToUserString(_ minor: Int64, minorUnit: Int) -> String {
        if minorUnit <= 0 { return "\(minor)" }

        let sign = minor < 0 ? "-" : ""
        let absVal = minor < 0 ? -minor : minor

        let divisor = Int64(pow(10.0, Double(minorUnit)))
        let intPart = absVal / divisor
        let fracPart = absVal % divisor

        let frac = String(format: "%0*lld", minorUnit, fracPart)
        return "\(sign)\(intPart).\(frac)"
    }
}
