import SwiftUI
import Foundation

class SessionManager {
    static let shared = SessionManager()
    let uuid: String

    private init() {
        self.uuid = UUID().uuidString
    }
}

struct WelcomeView: View {
    @State private var navigateToAchievement = false

    var body: some View {
        NavigationStack {
            ZStack {
                BreathingBackground()
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Image("success_moon")
                            .resizable()
                            .frame(width: 120, height: 130)
                            .accessibilityHidden(true)
                        Text("Welcome to your new beginning of rest.")
                            .font(.custom("Sora-Bold", size: 24))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text("Your journey to better sleep starts now.")
                            .font(.custom("Sora-Regular", size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    Spacer()
                    NavigationLink(
                        destination: AchievementView(),
                        isActive: $navigateToAchievement
                    ) {
                        Button(action: {
                            navigateToAchievement = true
                        }) {
                            Text("Start")
                                .font(.custom("Sora-SemiBold", size: 20))
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 64)
                                .background(Color(red: 124/255, green: 111/255, blue: 240/255))
                                .cornerRadius(40)
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    WelcomeView()
}