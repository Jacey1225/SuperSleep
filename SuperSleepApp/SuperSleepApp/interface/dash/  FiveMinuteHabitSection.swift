import SwiftUI

struct FiveMinuteHabitSection: View {
    var body: some View {
        HStack {
            Text("5 minutes of mindful breathing")
                .font(DashboardFonts.section)
                .foregroundColor(.white)
                .opacity(0.6)
            Spacer()
            Button(action: {}) {
                Text("/")
                    .font(DashboardFonts.sectionTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(DashboardColors.waveGradient)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(DashboardColors.card)
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}