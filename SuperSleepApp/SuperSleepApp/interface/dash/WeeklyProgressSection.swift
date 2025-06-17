import SwiftUI

struct WeeklyProgressSection: View {
    @Binding var barValues: [CGFloat]
    @Binding var healthyCount: Int
    let days: [String]
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
            // Add extra top padding here
            BarChartView(values: barValues, days: days)
                .frame(height: 100)
                .padding(.horizontal, 4)
                .padding(.top, 16) // <-- Add this line for more spacing
            Text("\(healthyCount) out of 7 nights of healthy sleep")
                .font(DashboardFonts.body)
                .foregroundColor(.white)
                .opacity(0.8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}