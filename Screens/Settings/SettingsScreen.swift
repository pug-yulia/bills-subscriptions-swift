import SwiftUI
import SwiftData

struct SettingsScreen: View {

    @Environment(\.modelContext) private var context

    @Query(sort: \Currency.name, order: .forward)
    private var currencies: [Currency]

    @Query
    private var settings: [AppSettings]

    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            List {

                // Валюта
                if let setting = settings.first {
                    CurrencySection(setting: setting, currencies: currencies)
                } else {
                    Section("App Currency") {
                        ProgressView()
                    }
                }

                // Сервис
                Section("Developer Tools") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        HStack {
                            Text("Reset Database")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }

                    Text("Deletes local data and recreates the database")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                // Прочее
                Section("Other") {
                    Text("Additional settings coming soon")
                        .foregroundStyle(.gray)
                }
            }
            .navigationTitle("Settings")
            .task {
                ensureSettingsExists()
            }
            .alert("Reset Database?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    do {
                        try DatabaseSeeder.resetAndSeed(context: context)
                    } catch {
                        print("Reset+Seed error:", error)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("All data will be deleted and recreated.")
            }
        }
    }

    // MARK: - Settings bootstrap

    @MainActor
    private func ensureSettingsExists() {
        if settings.isEmpty {
            let s = AppSettings(preferredCurrencyCode: "USD")
            context.insert(s)
            do {
                try context.save()
                print("✅ AppSettings created")
            } catch {
                print("❌ Failed to save AppSettings:", error)
            }
        }
    }
}

private struct CurrencySection: View {

    @Bindable var setting: AppSettings
    let currencies: [Currency]

    var body: some View {
        Section("App Currency") {

            Text("Amounts will be automatically converted to the selected currency")
                .font(.caption)
                .foregroundStyle(.gray)

            ForEach(currencies) { cur in
                Button {
                    setting.preferredCurrencyCode = cur.code
                } label: {
                    HStack(spacing: 12) {

                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(cur.name) (\(cur.code))")
                                .foregroundStyle(.primary)

                            Text("Minor unit: \(cur.minorUnit)")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }

                        Spacer()

                        if setting.preferredCurrencyCode == cur.code {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
