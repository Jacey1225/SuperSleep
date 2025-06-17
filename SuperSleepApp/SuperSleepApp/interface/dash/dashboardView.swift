import SwiftUI

struct DashboardView: View {
    @State private var waterPercent: CGFloat = 80
    @State private var barValues: [CGFloat] = [90, 40, 70, 80, 30, 85, 100]
    @State private var healthyCount: Int = 0
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let friends: [(name: String, progress: CGFloat)] = [
        ("Rachel Kim", 80), ("David Lee", 60), ("Mina Chen", 95), ("Alex Park", 45)
    ]

    var body: some View {
        ZStack {
            BreathingBackground()
            VStack(spacing: 0) {
                DashboardHeaderSection()
                DashboardDividerSection()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        TodaySummarySection(waterPercent: $waterPercent)
                        MicroHabitSection()
                        FiveMinuteHabitSection()
                        WeeklyProgressSection(barValues: $barValues, healthyCount: $healthyCount, days: days)
                        FriendsSection(friends: friends)
                        HabitsSection()
                    }
                    .padding(.bottom, 16)
                }
                DashboardDividerSection()
                DashboardFooterSection()
            }
        }
        .background(DashboardColors.background)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            healthyCount = barValues.filter { $0 >= 50 }.count
        }
    }
}

#Preview {
    DashboardView()
}
