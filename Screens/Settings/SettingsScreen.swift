import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @Environment(\.modelContext) private var context
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("Developer") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Text("Пересоздать демо-данные")
                    }
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
