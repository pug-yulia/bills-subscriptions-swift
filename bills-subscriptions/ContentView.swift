import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        TabsScreen()
            .task {
                do { try DatabaseSeeder.seedIfNeeded(context: context) }
                catch { print("Seed error:", error) }
            }
    }
}
