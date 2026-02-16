import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \Currency.name, order: .forward)
    private var currencies: [Currency]

    @Query
    private var settings: [AppSettings]

    @State private var showResetConfirm = false

    private var appSettings: AppSettings {
        if let s = settings.first { return s }
        // если вдруг нет — создадим на лету (один раз)
        let s = AppSettings(preferredCurrencyCode: "USD")
        context.insert(s)
        try? context.save()
        return s
    }

    var body: some View {
        NavigationStack {
            List {

                Section("Валюта приложения") {
                    Text("Суммы и итоги будут автоматически пересчитаны в выбранную валюту")
                        .font(.caption)
                        .foregroundStyle(.gray)

                    ForEach(currencies) { cur in
                        Button {
                            appSettings.preferredCurrencyCode = cur.code
                            try? context.save()
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

                                if appSettings.preferredCurrencyCode == cur.code {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                Section("Сервис") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        HStack {
                            Text("Сбросить базу данных")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                    Text("Удаляет локальные данные и пересоздаёт БД (полезно после изменения схемы)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }

                Section("Прочее") {
                    Text("Дополнительные настройки будут добавлены позже")
                        .foregroundStyle(.gray)
                }
            }
            .navigationTitle("Settings")
            .alert("Пересоздать данные?", isPresented: $showResetConfirm) {
                Button("Пересоздать", role: .destructive) {
                    do { try DatabaseSeeder.resetAndSeed(context: context) }
                    catch { print("Reset+Seed error:", error) }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Все категории и записи будут удалены и созданы заново.")
            }
        }
    }
}
