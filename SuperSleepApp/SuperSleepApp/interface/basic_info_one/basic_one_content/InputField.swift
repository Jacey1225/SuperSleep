import SwiftUI

struct InputField: View {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType = .default
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.custom("Sora", size: 16))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color(red: 30/255, green: 42/255, blue: 56/255).opacity(0.4))
            .cornerRadius(8)
            .keyboardType(keyboardType)
    }
}