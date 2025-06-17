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

struct ContentView: View {
    var body: some View {
        WelcomeView()
    }
}

#Preview {
    ContentView()
}
