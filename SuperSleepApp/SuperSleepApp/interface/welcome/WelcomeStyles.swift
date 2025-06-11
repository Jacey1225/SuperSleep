import SwiftUI

// MARK: - Background

struct BreathingBackground: View {
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

// MARK: - Modifiers

struct MoonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 120, height: 130)
            .padding(.top, 0)
            .padding(.bottom, 0)
    }
}

struct TextContainerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 0)
            .multilineTextAlignment(.center)
    }
}

struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Bold", size: 22))
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.bottom, 4)
            .lineSpacing(4)
    }
}

struct SubtitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Regular", size: 16))
            .foregroundColor(.white)
            .padding(.horizontal)
    }
}

struct ButtonContainerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom, 32)
    }
}

struct ButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(hex: "#7C6FF0"))
            .cornerRadius(40)
    }
}

struct ButtonTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Regular", size: 18))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 64)
    }
}

// MARK: - Hex Color Helper

extension Color {
    init(hex: String) {
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}