import SwiftUI

struct WeeklyProgressSection: View {
    @State private var barValues: [CGFloat] = []
    @State private var days: [String] = []
    @State private var healthyCount: Int = 0
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Weekly progress")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
                Spacer()
                Text(">")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
            }
            .padding(.horizontal, 16)
            if isLoading {
                ProgressView()
                    .frame(height: 100)
            } else {
                BarChartView(values: barValues, days: days)
                    .frame(height: 100)
                    .padding(.horizontal, 4)
                    .padding(.top, 16)
                Text("\(healthyCount) out of \(days.count) nights of healthy sleep")
                    .font(DashboardFonts.body)
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear {
            let uuid = SessionManager.shared.uuid
            WeeklyProgressService.getWeeklyProgress(uuid: uuid) { result in
                switch result {
                case .success(let weekData):
                    self.days = weekData.map { $0.0 }
                    self.barValues = weekData.map { $0.1 }
                    self.healthyCount = weekData.filter { $0.1 >= 50 }.count
                    self.isLoading = false
                case .failure:
                    self.days = []
                    self.barValues = []
                    self.healthyCount = 0
                    self.isLoading = false
                }
            }
        }
    }
}