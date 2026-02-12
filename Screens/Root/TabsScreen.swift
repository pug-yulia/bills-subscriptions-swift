import SwiftUI

struct TabsScreen: View {

    @State private var selectedTab = 0
    @State private var showAddPayment = false

    var body: some View {
        ZStack(alignment: .bottom) {

            TabView(selection: $selectedTab) {

                NavigationStack {
                    HomeScreen()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

                NavigationStack {
                    BillsScreen()
                }
                .tabItem {
                    Label("Bills", systemImage: "doc.text")
                }
                .tag(1)

                NavigationStack {
                    SubscriptionsScreen()
                }
                .tabItem {
                    Label("Subscriptions", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(2)

                NavigationStack {
                    SettingsScreen()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
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
