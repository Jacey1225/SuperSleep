import SwiftUI

struct DashboardView: View {
    @State private var waterPercent: CGFloat = 0
    @State private var habits: [(name: String, progress: Int, total: Int)] = []
    @Binding var path: [AppPage]

    func loadHabits() {
        GetHabitsService.getMicroHabits(uuid: SessionManager.shared.uuid) { result in
            switch result {
            case .success(let habitsDict):
                self.habits = habitsDict.map { (key, value) in
                    (name: key, progress: value[0], total: value[1])
                }
                .sorted { $0.name < $1.name }
            case .failure:
                self.habits = []
            }
        }
    }

    var body: some View {
        ZStack {
            BreathingBackground()
            VStack(spacing: 0) {
                DashboardHeaderSection()
                DashboardDividerSection()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        TodaySummarySection(waterPercent: $waterPercent)
                        FiveMinuteHabitSection(habit: habits.first?.name ?? "—")
                        WeeklyProgressSection()
                        FriendsSection(onArrowTap: {
                            path.append(.leaderboard)
                        })
                        HabitsSection(
                            habits: $habits,
                            onArrowTap: {
                                path.append(.habits)
                            },
                            onHabitCompleted: { loadHabits() } 
                        )
                    }
                    .padding(.bottom, 16)
                }
                DashboardDividerSection()
                DashboardFooterSection(
                    onHabitsTap: {
                        path.append(.habits)
                    },
                    onHomeTap: { path.append(.dashboard) }
                )
            }
        }
        .padding(.top, 30)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            loadHabits()
            SleepQualityService.getSleepQuality(uuid: SessionManager.shared.uuid) { result in
                if case let .success(percent) = result {
                    waterPercent = CGFloat(percent)
                }
            }
        }
    }
}

#Preview {
    DashboardView(path: .constant([]))
}
