import SwiftUI

struct ProgressCircle: View {
    let current: Int
    let total: Int

    var percent: CGFloat {
        total > 0 ? CGFloat(current) / CGFloat(total) : 0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 47/255, green: 47/255, blue: 55/255), lineWidth: 10)
                .frame(width: 100, height: 100)
            Circle()
                .trim(from: 0, to: percent)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#563AC8"), Color(hex: "#5280A5")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 100, height: 100)
                .animation(.easeOut(duration: 1.2), value: percent)
            Text("\(current)/\(total)")
                .font(.custom("Sora-Bold", size: 22))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}