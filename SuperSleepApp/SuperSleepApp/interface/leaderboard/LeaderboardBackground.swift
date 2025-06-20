import SwiftUI

struct LeaderboardBackground: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 30/255, green: 42/255, blue: 56/255)
                    .ignoresSafeArea()
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 74/255, green: 101/255, blue: 149/255),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: animate ? geo.size.width * 0.7 : geo.size.width * 0.5
                )
                .opacity(animate ? 0.95 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
                .onAppear {
                    animate = true
                }
            }
        }
    }
}