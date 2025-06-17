import SwiftUI

enum DashboardColors {
    static let background = Color(red: 30/255, green: 42/255, blue: 56/255)
    static let divider = Color(red: 41/255, green: 48/255, blue: 53/255)
    static let accent = Color(red: 165/255, green: 190/255, blue: 212/255)
    static let card = Color(red: 43/255, green: 61/255, blue: 79/255).opacity(0.4)
    static let barHealthy = LinearGradient(
        gradient: Gradient(colors: [Color(red: 8/255, green: 103/255, blue: 95/255), Color(red: 63/255, green: 102/255, blue: 138/255)]),
        startPoint: .bottom, endPoint: .top)
    static let barUnhealthy = Color(red: 46/255, green: 70/255, blue: 94/255)
    static let waveGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 82/255, green: 128/255, blue: 165/255), Color(red: 86/255, green: 58/255, blue: 200/255)]),
        startPoint: .top, endPoint: .bottom)
}

enum DashboardFonts {
    static let header = Font.custom("Sora", size: 24)
    static let sectionTitle = Font.custom("Sora", size: 22)
    static let section = Font.custom("Sora", size: 16)
    static let body = Font.custom("Sora", size: 14)
}