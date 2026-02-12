import SwiftUI

struct HomeRowItemView: View {
    let iconSystemName: String
    let title: String
    let subtitle: String
    let rightText: String

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: iconSystemName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            Spacer()

            Text(rightText)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding(.vertical, 8)
    }
}
