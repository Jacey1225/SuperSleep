import SwiftUI

struct FooterButton: View {
    let label: String
    var isActive: Bool = false
    var body: some View {
        VStack(spacing: 4) {
            Image("sprofile")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(isActive ? Color(hex: "#A6ABFB") : Color(red: 118/255, green: 119/255, blue: 140/255))
            Text(label)
                .font(.custom("Sora-Regular", size: 14))
                .foregroundColor(isActive ? Color(hex: "#A6ABFB") : Color(red: 118/255, green: 119/255, blue: 140/255))
        }
        .frame(maxWidth: .infinity)
    }
}