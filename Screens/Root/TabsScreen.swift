import SwiftUI

struct TabsScreen: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem { Label("Home", systemImage: "house") }

            BillsScreen()
                .tabItem { Label("Bills", systemImage: "doc.text") }

            SubscriptionsScreen()
                .tabItem { Label("Subs", systemImage: "arrow.triangle.2.circlepath") }

            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
