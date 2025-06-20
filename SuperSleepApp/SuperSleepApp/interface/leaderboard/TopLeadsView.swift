import SwiftUI

struct TopLeadsView: View {
    let topFriends: [(String, CGFloat)]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<min(3, topFriends.count), id: \.self) { idx in
                TopLeadCard(
                    name: topFriends[idx].0,
                    percent: topFriends[idx].1,
                    rank: idx + 1
                )
            }
        }
        .padding(.vertical, 8)
    }
}