import SwiftUI

struct FriendCard: View {
    let rank: Int
    let name: String
    let percent: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Text("\(rank)")
                        .font(.custom("Sora-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(width: 24)
                    Image("sprofile")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Text(name)
                        .font(.custom("Sora-SemiBold", size: 16))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("\(Int(percent))%")
                    .font(.custom("Sora-Regular", size: 16))
                    .foregroundColor(.white)
            }
            ProgressBar(percent: percent)
                .frame(height: 8)
                .padding(.leading, 40)
        }
        .padding()
        .background(Color(red: 43/255, green: 61/255, blue: 79/255).opacity(0.4))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}