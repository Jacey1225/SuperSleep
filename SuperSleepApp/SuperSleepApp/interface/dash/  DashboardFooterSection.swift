import SwiftUI

struct DashboardFooterSection: View {
    var onHabitsTap: () -> Void = {}
    var onHomeTap: () -> Void = {}

    var body: some View {
        HStack {
            DashboardFooterButton(label: "Home", action: onHomeTap)
            DashboardFooterButton(label: "Habits", action: onHabitsTap)
            DashboardFooterButton(label: "History")
            DashboardFooterButton(label: "Home", isSettings: true, action: onHomeTap) 
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(DashboardColors.background)
    }
}