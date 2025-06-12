import SwiftUI
import HealthKit

class HealthDataManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var heartRate: Double?
    @Published var dailySteps: Int?

    func requestAuthorizationAndFetchData() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set = [heartRateType, stepCountType]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            guard success else { return }
            self?.fetchLatestHeartRate()
            self?.fetchTodaySteps()
        }
    }

    private func fetchLatestHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, _ in
            if let sample = samples?.first as? HKQuantitySample {
                let value = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    self?.heartRate = value
                }
            }
        }
        healthStore.execute(query)
    }

    private func fetchTodaySteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            if let sum = result?.sumQuantity() {
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                DispatchQueue.main.async {
                    self?.dailySteps = steps
                }
            }
        }
        healthStore.execute(query)
    }
}

struct Device: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    var isSelected: Bool = false
}

struct DevicesView: View {
    @StateObject private var healthDataManager = HealthDataManager()
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
                            // Only request HealthKit for Apple Health
                            if devices[idx].title == "Apple Health" && devices[idx].isSelected {
                                healthDataManager.requestAuthorizationAndFetchData()
                            }
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