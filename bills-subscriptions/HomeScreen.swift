import SwiftUI

struct HomeScreen: View {
    
    let bills = [
            ("Electricity Bill", "$120"),
            ("Water Bill", "$45")
        ]
        
        let subscriptions = [
            ("Netflix", "$15 /month"),
            ("Spotify", "$10 /month")
        ]
    
    var greeting: String {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 {
                return "Good morning ☀️"
            } else if hour < 18 {
                return "Good afternoon 🌤️"
            } else {
                return "Good evening 🌙"
            }
        }
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 20) {
                
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total This Month")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("$1,234.56")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.blue)
                .cornerRadius(22)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
            .background(.blue)
            .cornerRadius(32)
            
            
            ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Upcoming Bills")
                                        .font(.headline)
                                    
                                    ForEach(bills, id: \.0) { bill in
                                        HStack {
                                            Text(bill.0)
                                            Spacer()
                                            Text(bill.1)
                                                .fontWeight(.semibold)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Active Subscriptions")
                                        .font(.headline)
                                    
                                    ForEach(subscriptions, id: \.0) { sub in
                                        HStack {
                                            Text(sub.0)
                                            Spacer()
                                            Text(sub.1)
                                                .fontWeight(.semibold)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }
            
            Spacer()
        }
        .background(Color.white)
        //.ignoresSafeArea(edges: .top)
    }
}
