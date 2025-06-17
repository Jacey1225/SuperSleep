import SwiftUI

struct FriendsSection: View {
    let friends: [(name: String, progress: CGFloat)]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Friends & Family")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
                Spacer()
                Text(">")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
            }
            .padding(.horizontal, 16)
            ForEach(friends, id: \.name) { friend in
                FriendCardView(name: friend.name, progress: friend.progress)
            }
        }
    }
}