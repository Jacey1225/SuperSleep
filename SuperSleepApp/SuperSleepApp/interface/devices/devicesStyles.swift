import SwiftUI

struct MoonIconStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 80, height: 90)
            .padding(.top, 8)
    }
}

struct DevicesTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Bold", size: 22))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
    }
}

struct DevicesSubtitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Regular", size: 15))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }
}

struct DevicesSyncTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Regular", size: 14))
            .foregroundColor(.white.opacity(0.45))
    }
}

struct DevicesSkipStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Regular", size: 16))
            .foregroundColor(Color(hex: "#A6ABFB"))
            .padding(.vertical, 8)
    }
}

struct DevicesContinueButtonTextStyle: ViewModifier {
    let isEnabled: Bool
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-SemiBold", size: 17))
            .foregroundColor(isEnabled ? .white : Color(hex: "#A0A3B4"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
    }
}

struct DevicesContinueButtonStyle: ViewModifier {
    let isEnabled: Bool
    func body(content: Content) -> some View {
        content
            .background(isEnabled ? Color(hex: "#7C6FF0") : Color(hex: "#2F2F37"))
            .cornerRadius(40)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
    }
}

struct DeviceIconStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 40, height: 40)
            .padding(.leading, 8)
    }
}

struct DeviceCardTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Bold", size: 16))
            .foregroundColor(.white)
    }
}

struct DeviceCardDescriptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Sora-Regular", size: 13))
            .foregroundColor(.white.opacity(0.7))
    }
}

struct DevicePlusBackgroundStyle: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color(hex: "#00A492") : .black) 
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#1E2A38"), lineWidth: 4)
                )
            content
        }
    }
}

struct DevicePlusTextStyle: ViewModifier {
    let isSelected: Bool
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(isSelected ? .white : Color(hex: "#00A492"))
    }
}

struct DeviceCardContainerStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(32)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .padding(.horizontal, 16)
    }
}