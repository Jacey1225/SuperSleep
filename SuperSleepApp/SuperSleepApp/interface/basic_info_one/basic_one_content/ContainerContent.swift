import SwiftUI

struct ContainerContent<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color(red: 43/255, green: 61/255, blue: 79/255).opacity(0.4))
        .cornerRadius(8)
    }
}