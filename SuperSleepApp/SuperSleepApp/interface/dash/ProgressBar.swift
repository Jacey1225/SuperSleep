import SwiftUI

struct ProgressBar: View {
    let percent: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(DashboardColors.barUnhealthy)
                .frame(height: 8)
            RoundedRectangle(cornerRadius: 4)
                .fill(DashboardColors.waveGradient)
                .frame(width: CGFloat(percent), height: 8)
                .animation(.easeInOut(duration: 0.4), value: percent)
        }
    }
}