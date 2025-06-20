import SwiftUI

struct LeaderboardHeader: View {
    var body: some View {
        HStack {
            Text("<  Leaderboard")
                .foregroundColor(Color(hex: "#A6ABFB"))
                .font(.custom("Sora", size: 16))
                .padding(.leading, 16)
            Spacer()
        }
        .padding(.top, 32)
        .padding(.bottom, 8)
        .background(Color(red: 30/255, green: 42/255, blue: 56/255))
    }
}