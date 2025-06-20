import SwiftUI

struct MainContainers: View {
    @Binding var name: String
    @Binding var age: String
    @Binding var weight: String
    @Binding var height: String
    @Binding var gender: String
    @Binding var weightUnit: String
    @Binding var heightUnit: String
    @Binding var showGenderPicker: Bool
    @Binding var showWeightUnitPicker: Bool
    @Binding var showHeightUnitPicker: Bool

    var body: some View {
        VStack(spacing: 16) {
            ContainerContent {
                SubRow(image: "sprofile", label: "Name")
                InputField(text: $name, placeholder: "Enter your name")
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Gender")
                DropdownField(label: gender, onTap: { showGenderPicker = true })
                    .frame(maxWidth: .infinity) 
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Age")
                InputField(text: $age, placeholder: "Enter your age", keyboardType: .numberPad)
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Weight")
                HStack(spacing: 8) {
                    InputField(text: $weight, placeholder: "Enter your weight", keyboardType: .decimalPad)
                        .frame(maxWidth: .infinity)
                    Text("Lbs")
                        .font(.custom("Sora", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(Color(red: 30/255, green: 42/255, blue: 56/255).opacity(0.4))
                        .cornerRadius(8)
                }
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Height")
                HStack(spacing: 8) {
                    InputField(text: $height, placeholder: "Enter your height", keyboardType: .decimalPad)
                        .frame(maxWidth: .infinity)
                    Text("Ft")
                        .font(.custom("Sora", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(Color(red: 30/255, green: 42/255, blue: 56/255).opacity(0.4))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}