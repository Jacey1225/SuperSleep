import SwiftUI

struct MainContainersTwo: View {
    @Binding var activityMinutes: String
    @Binding var sleepDuration: String
    @Binding var stressLevel: Int
    @Binding var sleepDisorder: Bool?

    var body: some View {
        VStack(spacing: 16) {
            ContainerContent {
                SubRow(image: "sprofile", label: "Daily Physical Activity (minutes)")
                InputField(text: $activityMinutes, placeholder: "e.g. 30", keyboardType: .numberPad)
                    .frame(maxWidth: .infinity)
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Sleep Duration (hours)")
                InputField(text: $sleepDuration, placeholder: "e.g. 8", keyboardType: .numberPad)
                    .frame(maxWidth: .infinity)
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Estimated Stress Level")
                StressSlider(stressLevel: $stressLevel)
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Do you have any sleep disorders?")
                HStack {
                    DisorderButtons(selected: $sleepDisorder)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }
}