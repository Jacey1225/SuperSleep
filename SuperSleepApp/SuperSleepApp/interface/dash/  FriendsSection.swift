import SwiftUI

struct FriendsSection: View {
    @State private var friends: [(name: String, percent: CGFloat)] = []
    @State private var isLoading = true
    @State private var notInGroup = false
    var onArrowTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Friends & Family")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
                Spacer()
                Button(action: onArrowTap) {
                    Text(">")
                        .font(DashboardFonts.section)
                        .foregroundColor(DashboardColors.accent)
                }
            }
            .padding(.horizontal, 16)
            if isLoading {
                ProgressView()
                    .padding()
            } else if notInGroup {
                Text("You are not in a group yet!")
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            } else {
                ForEach(friends, id: \.name) { friend in
                    FriendCardView(name: friend.name, percent: friend.percent)
                }
            }
        }
        .onAppear {
            let uuid = SessionManager.shared.uuid
            GroupService.getGroupId(uuid: uuid) { result in
                switch result {
                case .success(let groupId):
                    if let groupId = groupId, !groupId.isEmpty {
                        GroupService.getTopFriends(groupId: groupId) { result in
                            switch result {
                            case .success(let topFriends):
                                self.friends = topFriends
                                self.notInGroup = false
                                self.isLoading = false
                            case .failure:
                                self.friends = []
                                self.notInGroup = false
                                self.isLoading = false
                            }
                        }
                    } else {
                        self.notInGroup = true
                        self.isLoading = false
                    }
                case .failure:
                    self.notInGroup = true
                    self.isLoading = false
                }
            }
        }
    }
}