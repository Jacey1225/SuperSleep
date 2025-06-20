import SwiftUI

struct DashboardHeaderSection: View {
    var body: some View {
        HStack {
            Image("headertitle")
                .renderingMode(.original)
                .padding(.leading, 24)
            Spacer()
            Image("sprofile")
                .resizable()
                .frame(width: 36, height: 36)
                .padding(.trailing, 24)
        }
        .padding(.top,  UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.safeAreaInsets.top ?? 44)
        .padding(.vertical, 16)
    }
}