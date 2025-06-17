import SwiftUI

struct SubRow: View {
    let image: String
    let label: String
    var body: some View {
        HStack(spacing: 8) {
            Image(image)
                .resizable()
                .frame(width: 28, height: 28)
            Text(label)
                .font(.custom("Sora", size: 16))
                .foregroundColor(Color(red: 165/255, green: 190/255, blue: 212/255))
        }
        .padding(.bottom, 2)
    }
}