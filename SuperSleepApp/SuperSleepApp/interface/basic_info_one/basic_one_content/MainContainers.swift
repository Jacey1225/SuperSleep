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
                    DropdownField(label: weightUnit, onTap: { showWeightUnitPicker = true })
                        .frame(width: 80)
                }
            }
            ContainerContent {
                SubRow(image: "sprofile", label: "Height")
                HStack(spacing: 8) {
                    InputField(text: $height, placeholder: "Enter your height", keyboardType: .decimalPad)
                        .frame(maxWidth: .infinity)
                    DropdownField(label: heightUnit, onTap: { showHeightUnitPicker = true })
                        .frame(width: 80)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}