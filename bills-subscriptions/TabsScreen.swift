import SwiftUI

struct TabsScreen: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeScreen()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                
                BillsScreen()
                    .tabItem {
                        Image(systemName: "doc.text")
                        Text("Bills")
                    }
                    .tag(1)
                
                SubscriptionsScreen()
                    .tabItem {
                        Image(systemName: "creditcard")
                        Text("Subscriptions")
                    }
                    .tag(2)
                
                SettingsScreen()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(3)
            }
            
            VStack {
                Spacer()
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 56, height: 56)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 28))
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}
