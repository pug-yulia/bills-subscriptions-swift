import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    // сделать правильно
                } label: {
                    HStack {
                        Text("Reset DB (placeholder)")
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}
