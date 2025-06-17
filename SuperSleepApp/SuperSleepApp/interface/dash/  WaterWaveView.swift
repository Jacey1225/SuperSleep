import SwiftUI

struct WaterWaveView: View {
    @Binding var percent: CGFloat
    @State private var waveOffset: CGFloat = 0
    var body: some View {
        ZStack {
            Circle()
                .fill(DashboardColors.card)
                .shadow(color: Color(red: 86/255, green: 58/255, blue: 200/255), radius: 12)
            WaveShape(percent: percent, waveOffset: waveOffset)
                .fill(DashboardColors.waveGradient)
                .clipShape(Circle())
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: waveOffset)
                .onAppear { waveOffset = 1 }
            Text("\(Int(percent))/100")
                .font(DashboardFonts.sectionTitle)
                .foregroundColor(DashboardColors.accent)
                .bold()
        }
    }
}

struct WaveShape: Shape {
    var percent: CGFloat
    var waveOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight: CGFloat = 10
        let yOffset = rect.height * (1 - percent / 100)
        path.move(to: CGPoint(x: 0, y: rect.height))
        for x in stride(from: 0, to: rect.width + 1, by: 1) {
            let relativeX = x / rect.width
            let sine = sin((relativeX + waveOffset) * 2 * .pi)
            let y = yOffset + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }

    var animatableData: CGFloat {
        get { waveOffset }
        set { waveOffset = newValue }
    }
}