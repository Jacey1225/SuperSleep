import SwiftUI

struct AchievementView: View {
    var onContinue: () -> Void
    @State private var selectedChoice: Int? = nil
    @State private var showWhiteBox = false
    @State private var numberInput: String = ""
    @State private var timeRange: String = "Day"

    let choices = [
        ("shealth", "Sleep Better"),
        ("sflash", "More Energy"),
        ("semoji", "Reduce Anxiety")
    ]
    let timeOptions = ["Day", "Week", "Month"]

    var isFormComplete: Bool {
        selectedChoice != nil && !numberInput.isEmpty
    }

    var body: some View {
        ZStack {
            BreathingBackground()
                .ignoresSafeArea()
            VStack {
                Spacer()
                VStack {
                    Image("success_moon")
                        .resizable()
                        .frame(width: 60, height: 68)
                        .padding(.top, -32)

                    Text("What do you want to achieve?")
                        .font(.custom("Sora-Bold", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    HStack(spacing: 16) {
                        ForEach(0..<choices.count, id: \.self) { idx in
                            Button(action: {
                                selectedChoice = idx
                                showWhiteBox = true
                            }) {
                                VStack(spacing: 6) {
                                    Image(choices[idx].0)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    Text(choices[idx].1)
                                        .font(.custom("Sora-Regular", size: 13))
                                        .foregroundColor(selectedChoice == idx ? Color("AccentPurple") : .white)
                                }
                                .frame(width: 110, height: 110)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .modifier(AchievementChoiceStyle(isSelected: selectedChoice == idx))
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 12)

                    if showWhiteBox {
                        VStack(spacing: 8) {
                            Text("How quickly would you like to reach your goal?")
                                .font(.custom("Sora-Bold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text("This helps us tailor your plan to your pace.")
                                .font(.custom("Sora-Regular", size: 12))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                            VStack(spacing: 0) {
                                Text("Number of Units")
                                    .font(.custom("Sora-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                TextField("", text: $numberInput)
                                    .keyboardType(.numberPad)
                                    .frame(width: 60)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 40/255, green: 40/255, blue: 60/255, opacity: 0.7))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color("AccentPurple"), lineWidth: 1)
                                    )
                                    .foregroundColor(.white)
                                    .font(.custom("Sora-Regular", size: 14))
                                    .padding(.bottom, 8)
                            }
                            .padding(.horizontal, 8)
                            VStack(spacing: 0) {
                                Text("Time Range")
                                    .font(.custom("Sora-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                Picker("", selection: $timeRange) {
                                    ForEach(timeOptions, id: \.self) { option in
                                        Text(option).tag(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 100)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 40/255, green: 40/255, blue: 60/255, opacity: 0.7))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color("AccentPurple"), lineWidth: 1)
                                )
                                .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 4)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 14).stroke(Color("AccentPurple"), lineWidth: 2))
                        .padding(.horizontal, 8)
                        .padding(.top, 16)
                    }
                }
                Spacer()
                Button(action: {
                    if isFormComplete {
                        let selectedGoal = choices[selectedChoice ?? 0].1
                        let growthRate = "\(numberInput) \(timeRange)"
                        GoalService.setGoals(
                            uuid: SessionManager.shared.uuid,
                            goal: selectedGoal,
                            growthRate: growthRate
                        ) { result in
                            onContinue()
                        }
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
                .disabled(!isFormComplete)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    AchievementView(onContinue: {})
        .background(Color.black)
}