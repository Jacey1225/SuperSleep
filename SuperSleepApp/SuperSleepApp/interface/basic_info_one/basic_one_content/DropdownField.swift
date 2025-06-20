import SwiftUI

struct DropdownField: View {
    let label: String
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .font(.custom("Sora", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color(red: 30/255, green: 42/255, blue: 56/255).opacity(0.4))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity) 
    }
}