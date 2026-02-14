import SwiftUI

enum Tab: Int {
    case home = 0
    case bills = 1
    case subscriptions = 2
    case settings = 3
}

struct TabsScreen: View {

    @State private var selectedTab: Tab = .home
    @State private var showAddPayment = false

    var body: some View {
        ZStack(alignment: .bottom) {

            TabView(selection: $selectedTab) {

                NavigationStack {
                    HomeScreen(selectedTab: $selectedTab)
                }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)

                NavigationStack {
                    BillsScreen()
                }
                .tabItem { Label("Bills", systemImage: "doc.text") }
                .tag(Tab.bills)

                NavigationStack {
                    SubscriptionsScreen()
                }
                .tabItem { Label("Subscriptions", systemImage: "arrow.triangle.2.circlepath") }
                .tag(Tab.subscriptions)

                NavigationStack {
                    SettingsScreen()
                }
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
            }

            // Центральная синяя кнопка
            Button {
                showAddPayment = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
            }
            .offset(y: -20) // выпирает вверх
        }
        .sheet(isPresented: $showAddPayment) {
            AddPaymentScreen()
        }
    }
}
