import SwiftUI

struct HomeSectionHeaderView: View {
    let title: String
    let onSeeAll: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Button(action: onSeeAll) {
                Text("See all")
                    .font(.subheadline)
            }
        }
        .padding(.top, 4)
    }
}
