import SwiftUI

struct DisorderButtons: View {
    @Binding var selected: Bool?
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { selected = true }) {
                Text("Yes")
                    .font(.custom("Sora", size: 16))
                    .foregroundColor(selected == true ? .white : Color(hex: "#A5BED4"))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(selected == true ? Color(hex: "#2F2F37") : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color(hex: "#1E2A38"), lineWidth: 3)
                    )
                    .cornerRadius(32)
            }
            Button(action: { selected = false }) {
                Text("No")
                    .font(.custom("Sora", size: 16))
                    .foregroundColor(selected == false ? .white : Color(hex: "#A5BED4"))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(selected == false ? Color(hex: "#2F2F37") : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color(hex: "#1E2A38"), lineWidth: 3)
                    )
                    .cornerRadius(32)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}