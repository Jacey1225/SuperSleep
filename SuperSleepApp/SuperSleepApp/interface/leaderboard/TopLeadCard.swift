import SwiftUI

struct TopLeadCard: View {
    let name: String
    let percent: CGFloat
    let rank: Int

    var body: some View {
        VStack(spacing: 8) {
            Image("sprofile")
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .padding(.bottom, 4)
            Text(name)
                .font(.custom("Sora-SemiBold", size: 16))
                .foregroundColor(.white)
                .opacity(0.8)
            ProgressBar(percent: percent)
                .frame(height: 6)
                .padding(.horizontal, 8)
            Text("\(Int(percent))%")
                .font(.caption)
                .foregroundColor(.white)
                .opacity(0.5)
        }
        .frame(width: 120)
        .background(Color.clear)
        .cornerRadius(12)
    }
}