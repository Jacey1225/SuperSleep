import SwiftUI

struct TopSectionTwo: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("We found some data that can \nhelp you get started faster")
                    .font(.custom("Sora", size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button(action: {}) {
                    Text("Use this data")
                        .font(.custom("Sora", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 124/255, green: 111/255, blue: 240/255))
                        .cornerRadius(24)
                }
            }
            .padding(16)
            .background(Color(red: 43/255, green: 61/255, blue: 79/255).opacity(0.4))
            .cornerRadius(8)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
        }
    }
}