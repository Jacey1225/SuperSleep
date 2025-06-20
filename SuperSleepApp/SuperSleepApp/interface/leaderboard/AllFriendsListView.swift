import SwiftUI

struct AllFriendsListView: View {
    let friends: [(String, CGFloat)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(friends.indices, id: \.self) { idx in
                FriendCard(
                    rank: idx + 4,
                    name: friends[idx].0,
                    percent: friends[idx].1
                )
            }
        }
        .padding(.top, 8)
    }
}