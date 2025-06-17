//
//  SuperSleepAppApp.swift
//  SuperSleepApp
//
//  Created by Jacey Simpson on 6/10/25.

import SwiftUI

@main
struct SuperSleepAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

enum AppPage: Hashable {
    case welcome
    case achievement
    case basicInfoOne
    case basicInfoTwo
    case dashboard
}

struct ContentView: View {
    @State private var path: [AppPage] = []

    var body: some View {
        NavigationStack(path: $path) {
            WelcomeView {
                path.append(.achievement)
            }
            .navigationDestination(for: AppPage.self) { page in
                switch page {
                case .welcome:
                    WelcomeView {
                        path.append(.achievement)
                    }
                case .achievement:
                    AchievementView {
                        path.append(.basicInfoOne)
                    }
                case .basicInfoOne:
                    BasicInfoOneView {
                        path.append(.basicInfoTwo)
                    }
                case .basicInfoTwo:
                    BasicInfoTwoView {
                        path.append(.dashboard)
                    }
                case .dashboard:
                    DashboardView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
