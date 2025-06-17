import SwiftUI

struct HabitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Habits Progress")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
                Spacer()
                Text(">")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
            }
            .padding(.horizontal, 16)
            ForEach([
                ("Water", "6/8 glasses"),
                ("Night reading", "3/5 completed"),
                ("Avoid screens", "5/7 completed"),
                ("Meditation", "4/7 completed")
            ], id: \.0) { habit, progress in
                HabitRowView(habit: habit, progress: progress)
            }
        }
        .background(DashboardColors.card)
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}