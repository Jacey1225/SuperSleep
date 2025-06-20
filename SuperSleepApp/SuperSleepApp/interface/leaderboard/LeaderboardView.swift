import SwiftUI

struct LeaderboardView: View {
    @State private var topFriends: [(String, CGFloat)] = []
    @State private var allFriends: [(String, CGFloat)] = []
    @State private var isLoading = true
    @State private var groupId: String? = nil
    @State private var showJoinAlert = false
    @State private var joinGroupId = ""
    @State private var joinError: String?
    @State private var showInviteAlert = false
    @State private var inviteUsername = ""
    @State private var inviteError: String?
    @State private var leaveError: String?
    @State private var invitedGroupId: String? = nil
    @State private var showGroupIdOverlay = false

    private func loadGroupData() {
        isLoading = true
        let uuid = SessionManager.shared.uuid
        GroupService.getGroupId(uuid: uuid) { result in
            switch result {
            case .success(let groupId):
                if let groupId = groupId, !groupId.isEmpty {
                    self.groupId = groupId
                    GroupService.getTopFriends(groupId: groupId) { result in
                        if case let .success(top) = result {
                            self.topFriends = top
                        }
                    }
                    GroupService.getAllFriends(groupId: groupId) { result in
                        if case let .success(all) = result {
                            self.allFriends = all
                        }
                        self.isLoading = false
                    }
                } else {
                    self.groupId = nil
                    self.isLoading = false
                }
            case .failure:
                self.groupId = nil
                self.isLoading = false
            }
        }
    }

    var body: some View {
        ZStack {
            LeaderboardBackground()
                .ignoresSafeArea()
            VStack(spacing: 0) {
                LeaderboardHeader()
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Leaderboard")
                            .font(.custom("Sora-Bold", size: 24))
                            .foregroundColor(.white)
                            .padding(.top, 16)
                        Text("Friends & Family")
                            .font(.custom("Sora-Regular", size: 16))
                            .foregroundColor(Color(hex: "#A5BED4"))
                            .padding(.bottom, 8)
                        if isLoading {
                            ProgressView().padding()
                        } else if groupId == nil {
                            Text("No group found yet!")
                                .font(.custom("Sora-Bold", size: 18))
                                .foregroundColor(.white)
                                .padding(.vertical, 32)
                        } else {
                            TopLeadsView(topFriends: topFriends)
                            AllFriendsListView(friends: allFriends)
                        }
                    }
                }
                Spacer()
                if groupId == nil {
                    VStack(spacing: 16) {
                        Button(action: {
                            GroupService.createGroup(uuid: SessionManager.shared.uuid) { result in
                                loadGroupData()
                            }
                        }) {
                            Text("Create Group")
                                .font(.custom("Sora-SemiBold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 124/255, green: 111/255, blue: 240/255))
                                .cornerRadius(40)
                        }
                        .padding(.horizontal, 32)

                        Button(action: {
                            showJoinAlert = true
                        }) {
                            Text("Join Group")
                                .font(.custom("Sora-SemiBold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 124/255, green: 111/255, blue: 240/255))
                                .cornerRadius(40)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                    .alert("Join Group", isPresented: $showJoinAlert, actions: {
                        TextField("Enter Group ID", text: $joinGroupId)
                        Button("Join") {
                            GroupService.joinGroup(uuid: SessionManager.shared.uuid, groupId: joinGroupId) { result in
                                switch result {
                                case .success:
                                    loadGroupData() 
                                case .failure(let error):
                                    joinError = error.localizedDescription
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }, message: {
                        if let joinError = joinError {
                            Text(joinError)
                        }
                    })
                } else {
                    VStack(spacing: 16) {
                        Button(action: {
                            showInviteAlert = true
                        }) {
                            Text("Invite to Group")
                                .font(.custom("Sora-SemiBold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 124/255, green: 111/255, blue: 240/255))
                                .cornerRadius(40)
                        }
                        .padding(.horizontal, 32)
                        .alert("Invite to Group", isPresented: $showInviteAlert, actions: {
                            Button("Invite") {
                                GroupService.inviteToGroup(uuid: SessionManager.shared.uuid) { result in
                                    switch result {
                                    case .success(let groupId):
                                        invitedGroupId = groupId // <-- This will be shown in the overlay
                                        showGroupIdOverlay = true
                                    case .failure(let error):
                                        inviteError = error.localizedDescription
                                    }
                                }
                            }
                            Button("Cancel", role: .cancel) { }
                        }, message: {
                            if let inviteError = inviteError {
                                Text(inviteError)
                            }
                        })

                        Button(action: {
                            GroupService.leaveGroup(uuid: SessionManager.shared.uuid) { result in
                                switch result {
                                case .success:
                                    loadGroupData() 
                                case .failure(let error):
                                    leaveError = error.localizedDescription
                                }
                            }
                        }) {
                            Text("Leave Group")
                                .font(.custom("Sora-SemiBold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(40)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                    .alert("Leave Group Error", isPresented: Binding<Bool>(
                        get: { leaveError != nil },
                        set: { if !$0 { leaveError = nil } }
                    )) {
                        Button("OK", role: .cancel) { leaveError = nil }
                    } message: {
                        if let leaveError = leaveError {
                            Text(leaveError)
                        }
                    }
                }
            }
            if showGroupIdOverlay, let groupId = invitedGroupId {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("Group ID")
                        .font(.custom("Sora-Bold", size: 24))
                        .foregroundColor(.white)
                    Text(groupId) 
                        .font(.custom("Sora-SemiBold", size: 22))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 124/255, green: 111/255, blue: 240/255))
                        .cornerRadius(16)
                    Button("Close") {
                        showGroupIdOverlay = false
                    }
                    .font(.custom("Sora-SemiBold", size: 18))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 32)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(40)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
        }
        .onAppear {
            loadGroupData()
        }
    }
}