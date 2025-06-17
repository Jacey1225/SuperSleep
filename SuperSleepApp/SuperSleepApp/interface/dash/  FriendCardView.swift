import SwiftUI

struct FriendCardView: View {
    let name: String
    let progress: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(DashboardFonts.section)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(progress))%")
                    .font(DashboardFonts.section)
                    .foregroundColor(.white)
            }
            ProgressBar(progress: progress)
        }
        .padding()
        .background(DashboardColors.card)
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}