import SwiftUI

struct Device: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    var isSelected: Bool = false
}

struct DevicesView: View {
    @State private var devices = [
        Device(imageName: "successfitbit", title: "Fitbit", description: "Automatically sync your steps, workouts, and sleep."),
        Device(imageName: "successheart", title: "Google Fit", description: "Track and sync your fitness and sleep data effortlessly."),
        Device(imageName: "successapple", title: "Apple Health", description: "Connect to get complete insights from your Apple devices.")
    ]
    @State private var canContinue = false

    var body: some View {
        ZStack {
            BreathingBackground()
                .ignoresSafeArea()
            VStack(spacing: 10) {
                Image("success_moon")
                    .resizable()
                    .modifier(MoonIconStyle())
                VStack(spacing: 4) {
                    Text("Connect your health device")
                        .modifier(DevicesTitleStyle())
                    Text("Sync your activity and sleep data to get better, personalized insights.")
                        .modifier(DevicesSubtitleStyle())
                }
                .padding(.bottom, 0)
                ForEach(devices.indices, id: \.self) { idx in
                    DeviceCard(
                        device: devices[idx],
                        isSelected: devices[idx].isSelected,
                        onToggle: {
                            devices[idx].isSelected.toggle()
                            canContinue = devices.contains(where: { $0.isSelected })
                        }
                    )
                }
                Text("Sync your data for better results")
                    .modifier(DevicesSyncTextStyle())
                    .padding(.top, 8)
                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)

            VStack {
                Spacer()
                VStack(spacing: 10) {
                    Button(action: {
                        // Skip action
                    }) {
                        Text("Skip for now")
                            .modifier(DevicesSkipStyle())
                    }
                    .frame(maxWidth: .infinity)
                    Button(action: {
                        // Continue action
                    }) {
                        Text("Continue")
                            .modifier(DevicesContinueButtonTextStyle(isEnabled: canContinue))
                    }
                    .disabled(!canContinue)
                    .modifier(DevicesContinueButtonStyle(isEnabled: canContinue))
                }
                .background(Color.clear)
            }
            // For demonstration, show the fetched values:
            VStack {
                if let hr = healthDataManager.heartRate {
                    Text("Latest Heart Rate: \(Int(hr)) bpm")
                        .foregroundColor(.white)
                }
                if let steps = healthDataManager.dailySteps {
                    Text("Today's Steps: \(steps)")
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 40)
        }
    }
}

struct DeviceCard: View {
    let device: Device
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(device.imageName)
                .resizable()
                .modifier(DeviceIconStyle())
            VStack(alignment: .leading, spacing: 2) {
                Text(device.title)
                    .modifier(DeviceCardTitleStyle())
                Text(device.description)
                    .modifier(DeviceCardDescriptionStyle())
            }
            .padding(.leading, 12)
            Spacer()
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .modifier(DevicePlusBackgroundStyle(isSelected: isSelected))
                        .frame(width: 45, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "#1E2A38"), lineWidth: 2)
                        )
                    Text("+")
                        .modifier(DevicePlusTextStyle(isSelected: isSelected))
                        .font(.system(size: 22, weight: .bold))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 8)
        }
        .modifier(DeviceCardContainerStyle())
    }
}