import SwiftUI

struct AchievementChoiceStyle: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color(red: 124/255, green: 111/255, blue: 240/255).opacity(0.10) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(red: 124/255, green: 111/255, blue: 240/255) : Color.white.opacity(0.2), lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}