//
//  bills_subscriptionsApp.swift
//  bills-subscriptions
//
//  Created by Iuliia Emelianova on 4.2.2026.
//

import SwiftUI
import SwiftData
@main
struct bills_subscriptionsApp: App {
    var body: some Scene {
        WindowGroup {
            TabsScreen()
            //HomeScreen()
            //ContentView()
        }
        .modelContainer(for: [
            Category.self,
            PaymentEntry.self,
            PaymentOccurrence.self,
            Currency.self,
            ExchangeRate.self,
            AppSettings.self
        ])

        
    }
}
