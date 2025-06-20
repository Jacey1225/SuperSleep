import SwiftUI

struct FriendCardView: View {
    let name: String
    let percent: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(DashboardFonts.section)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(percent))%")
                    .font(DashboardFonts.section)
                    .foregroundColor(.white)
            }
            ProgressBar(percent: percent)
        }
        .padding()
        .background(DashboardColors.card)
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}