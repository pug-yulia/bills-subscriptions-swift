import SwiftUI

struct HomeHeaderView: View {
    let greeting: String
    let totalThisMonthText: String
    let upcomingBillsText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text(greeting)
                .font(.headline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                Text("Total This Month")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.75))

                Text(totalThisMonthText)
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.white)

                HStack {
                    Text("Upcoming Bills")
                        .font(.caption)
                        .foregroundStyle(Color.white.opacity(0.75))
                    Spacer()
                    Text(upcomingBillsText)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
            .background(Color(red: 0.10, green: 0.25, blue: 0.87)) // как в RN: темнее внутри
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.12, green: 0.29, blue: 1.0)) // как в RN: #1f4bff
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}
