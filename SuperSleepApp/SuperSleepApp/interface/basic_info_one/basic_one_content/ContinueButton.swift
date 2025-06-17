import SwiftUI

struct ContinueButton: View {
    var isEnabled: Bool
    var body: some View {
        Button(action: {}) {
            Text("Continue")
                .font(.custom("Sora", size: 18))
                .foregroundColor(isEnabled ? .white : Color(.systemGray3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isEnabled ? Color(red: 124/255, green: 111/255, blue: 240/255) : Color(red: 47/255, green: 47/255, blue: 55/255))
                .cornerRadius(40)
        }
        .padding(.horizontal, 32)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}