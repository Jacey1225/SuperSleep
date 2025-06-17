import SwiftUI

struct StressSlider: View {
    @Binding var stressLevel: Int

    var body: some View {
        VStack(spacing: 8) {
            Slider(
                value: Binding(
                    get: { Double(stressLevel) },
                    set: { stressLevel = Int($0) }
                ),
                in: 1...10,
                step: 1
            )
            .accentColor(Color(hex: "#19E8C9"))
            .padding(.horizontal, 8)
            Text("Stress Level: \(stressLevel)")
                .foregroundColor(.white)
                .opacity(0.7)
                .font(.custom("Sora", size: 15))
        }
        .padding(.top, 8)
    }
}

// Helper for hex colors
extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: opacity
        )
    }
}