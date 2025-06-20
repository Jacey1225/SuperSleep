import SwiftUI

struct BasicInfoTwoView: View {
    var onContinue: () -> Void

    @State private var activityMinutes: String = ""
    @State private var sleepDuration: String = ""
    @State private var stressLevel: Int = 1
    @State private var sleepDisorder: Bool? = nil

    var body: some View {
        ZStack {
            BreathingBackground()
            VStack(spacing: 0) {
                Spacer().frame(height: 24)
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Complete your basic information")
                            .font(.custom("Sora", size: 21, relativeTo: .title))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 32)
                            .padding(.bottom, 16)
                        TopSectionTwo()
                        MainContainersTwo(
                            activityMinutes: $activityMinutes,
                            sleepDuration: $sleepDuration,
                            stressLevel: $stressLevel,
                            sleepDisorder: $sleepDisorder
                        )
                        .padding(.top, 16)
                    }
                }
                Spacer()
                Button(action: {
                    let uuid = SessionManager.shared.uuid
                    let sleepDurationValue = sleepDuration
                    let activityValue = activityMinutes
                    let stressValue = stressLevel
                    let disordersValue = (sleepDisorder == true) ? "Yes" : "No"

                    AdditionalInfoService.sendAdditionalInfo(
                        uuid: uuid,
                        sleepDuration: sleepDurationValue,
                        activity: activityValue,
                        stress: stressValue,
                        disorders: disordersValue
                    ) { result in
                        onContinue()
                    }
                }) {
                    Text("Continue")
                        .font(.custom("Sora-SemiBold", size: 20))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 64)
                        .background(Color(red: 124/255, green: 111/255, blue: 240/255))
                        .cornerRadius(40)
                }
                .padding(.bottom, 32)
            }
            .padding(.top, 48)
        }
        .background(Color(red: 30/255, green: 42/255, blue: 56/255))
        .edgesIgnoringSafeArea(.all)
        .font(.custom("Sora", size: 16))
    }
}

#Preview {
    BasicInfoTwoView(onContinue: {})
}
