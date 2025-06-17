import SwiftUI

struct DashboardHeaderSection: View {
    var body: some View {
        HStack {
            Text("SuperSLeepAI")
                .font(DashboardFonts.header)
                .foregroundColor(.white)
                .padding(.leading, 24)
            Spacer()
            Image("sprofile")
                .resizable()
                .frame(width: 36, height: 36)
                .padding(.trailing, 24)
        }
        .padding(.vertical, 24)
        .background(DashboardColors.background)
    }
}