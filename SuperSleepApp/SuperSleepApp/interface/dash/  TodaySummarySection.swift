import SwiftUI

struct TodaySummarySection: View {
    @Binding var waterPercent: CGFloat
    @State private var username: String = "John"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hi \(username)!")
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
            Text(waterPercent > 75 ?
                 "Your sleep quality is close to optimal." :
                 "Your sleep quality needs some attention")
                .font(.custom("Sora-SemiBold", size: 16))
                .foregroundColor(.white)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear {
            UsernameService.getUsername(uuid: SessionManager.shared.uuid) { result in
                if case let .success(name) = result {
                    username = name
                }
            }
        }
        .padding(.vertical, 16)
    }
}