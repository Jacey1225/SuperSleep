import SwiftUI

struct MicroHabitSection: View {
    var body: some View {
        HStack {
            Text("Your micro-habit today")
                .font(DashboardFonts.section)
                .foregroundColor(DashboardColors.accent)
            Spacer()
            Text(">")
                .font(DashboardFonts.section)
                .foregroundColor(DashboardColors.accent)
        }
        .padding(.horizontal, 16)
    }
}