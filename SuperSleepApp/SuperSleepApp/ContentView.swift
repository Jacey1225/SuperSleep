//
//  SuperSleepAppApp.swift
//  SuperSleepApp
//  Group Code: 05CZ1Owo
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
    case devices
    case loading
    case dashboard
    case habits
    case leaderboard
}

struct ContentView: View {
    @State private var path: [AppPage] = [] 
    @State private var hasDevice: Bool = false 

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
                        path.append(.devices)
                    }
                case .devices:
                    DevicesView(
                        onContinue: {
                            hasDevice = true
                            path.append(.loading)
                        },
                        onSkip: {
                            hasDevice = false
                            path.append(.loading)
                        }
                    )
                case .loading:
                    LoadingView(hasDevice: hasDevice) {
                        path.append(.dashboard)
                    }
                case .dashboard:
                    DashboardView(path: $path) 
                case .habits:        
                    HabitsView(onHomeTap: { path = [.dashboard] })
                case .leaderboard:
                    LeaderboardView() 
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
