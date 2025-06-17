import SwiftUI

struct DashboardFooterButton: View {
    let label: String
    var isSettings: Bool = false
    var body: some View {
        VStack(spacing: 4) {
            Image("sprofile")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(DashboardColors.accent)
            Text(label)
                .font(DashboardFonts.body)
                .foregroundColor(isSettings ? DashboardColors.accent : Color(red: 118/255, green: 119/255, blue: 140/255))
        }
        .frame(maxWidth: .infinity)
    }
}