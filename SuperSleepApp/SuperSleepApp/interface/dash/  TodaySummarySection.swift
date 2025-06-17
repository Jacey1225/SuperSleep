import SwiftUI

struct TodaySummarySection: View {
    @Binding var waterPercent: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi John!")
                .font(DashboardFonts.sectionTitle)
                .foregroundColor(.white)
                .padding(.leading, 16)
            Text("Today's Summary")
                .font(DashboardFonts.section)
                .foregroundColor(DashboardColors.accent)
                .padding(.leading, 16)
            WaterWaveView(percent: $waterPercent)
                .frame(width: 140, height: 140)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
            Text("Your sleep quality is close to optimal.")
                .font(DashboardFonts.body)
                .foregroundColor(.white)
                .opacity(0.6)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}