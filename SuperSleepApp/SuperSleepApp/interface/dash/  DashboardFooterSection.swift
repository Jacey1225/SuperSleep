import SwiftUI

struct DashboardFooterSection: View {
    var body: some View {
        HStack {
            DashboardFooterButton(label: "Home")
            DashboardFooterButton(label: "Habits")
            DashboardFooterButton(label: "History")
            DashboardFooterButton(label: "Settings", isSettings: true)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(DashboardColors.background)
    }
}