import SwiftUI

struct DashboardBreathingBackground: View {
    @State private var scale: CGFloat = 1.0
    var body: some View {
        DashboardColors.background
            .ignoresSafeArea()
            .scaleEffect(scale)
            .animation(
                Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear { scale = 1.35 }
            .zIndex(-1)
    }
}