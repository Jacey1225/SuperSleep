import SwiftUI

struct LoadingView: View {
    var hasDevice: Bool
    var onComplete: () -> Void
    @State private var animate = false
    @State private var currentCategoryIndex = 0
    @State private var opacity: Double = 1.0

    let categories = ["Name", "Age", "Gender", "Height", "Weight", "Sleep Duration", "Sleep Quality", "Sleep Habits"]
    let displayDuration: Double = 0.6 // seconds per category
    let totalDuration: Double = 2.5   // total loading time

    var body: some View {
        ZStack {
            // Animated glowing background
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 86/255, green: 58/255, blue: 200/255).opacity(0.7),
                    Color(red: 82/255, green: 128/255, blue: 165/255).opacity(0.7),
                    Color(red: 30/255, green: 42/255, blue: 56/255)
                ]),
                center: .center,
                startRadius: animate ? 120 : 80,
                endRadius: animate ? 400 : 300
            )
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("We’re analyzing your data to\ncreate your personalized sleep profile…")
                    .font(.custom("Sora-Bold", size: 22))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.white.opacity(0.5))
                    Text(categories[currentCategoryIndex])
                        .foregroundColor(.white.opacity(0.5))
                        .font(.custom("Sora-Regular", size: 18))
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.8), value: opacity)
                }
            }
        }
        .onAppear {
            animate = true

            // Call MicroHabitsService with hasDevice
            MicroHabitsService.fetchMicroHabits(
                uuid: SessionManager.shared.uuid,
                hasDevice: hasDevice
            ) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    LoadingView(hasDevice: true, onComplete: {})
}