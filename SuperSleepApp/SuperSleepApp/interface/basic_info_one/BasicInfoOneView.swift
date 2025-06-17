import SwiftUI

struct BasicInfoOneView: View {
    var onContinue: () -> Void

    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var gender: String = "Gender"
    @State private var weightUnit: String = "Kg"
    @State private var heightUnit: String = "M"
    @State private var showGenderPicker = false
    @State private var showWeightUnitPicker = false
    @State private var showHeightUnitPicker = false

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
                        TopSection()
                        MainContainers(
                            name: $name,
                            age: $age,
                            weight: $weight,
                            height: $height,
                            gender: $gender,
                            weightUnit: $weightUnit,
                            heightUnit: $heightUnit,
                            showGenderPicker: $showGenderPicker,
                            showWeightUnitPicker: $showWeightUnitPicker,
                            showHeightUnitPicker: $showHeightUnitPicker
                        )
                        .padding(.top, 16)
                    }
                }
                Spacer()
                Button(action: {
                    onContinue()
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
        .sheet(isPresented: $showGenderPicker) {
            PickerSheet(title: "Gender", selection: $gender, options: ["Male", "Female", "Prefer not to say"])
        }
        .sheet(isPresented: $showWeightUnitPicker) {
            PickerSheet(title: "Weight Unit", selection: $weightUnit, options: ["Kg", "Lbs"])
        }
        .sheet(isPresented: $showHeightUnitPicker) {
            PickerSheet(title: "Height Unit", selection: $heightUnit, options: ["M", "Ft"])
        }
    }
}

#Preview {
    BasicInfoOneView(onContinue: {})
}