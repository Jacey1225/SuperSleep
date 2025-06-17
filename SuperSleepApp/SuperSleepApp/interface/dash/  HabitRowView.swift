import SwiftUI

struct HabitRowView: View {
    let habit: String
    let progress: String
    var body: some View {
        HStack {
            Image("sprofile")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(DashboardColors.accent)
            Text(habit)
                .font(DashboardFonts.section)
                .foregroundColor(.white)
                .padding(.leading, 8)
            Spacer()
            Text(progress)
                .font(DashboardFonts.body)
                .foregroundColor(.white)
                .opacity(0.7)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
    }
}