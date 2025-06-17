import SwiftUI
import Foundation

struct AchievementView: View {
    @State private var selectedChoice: Int? = nil
    @State private var showWhiteBox = false
    @State private var numberInput: String = ""
    @State private var timeRange: String = "Day"
    @State private var navigateToDevices = false

    let uuid = SessionManager.shared.uuid
    
    let choices = [
        ("shealth", "Sleep Better"),
        ("sflash", "More Energy"),
        ("semoji", "Reduce Anxiety")
    ]
    let timeOptions = ["Day", "Week", "Month"]
    
    var body: some View {
        NavigationStack {
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
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 120, height: 110)
                                    .padding(.vertical, 8)
                                    .contentShape(Rectangle())
                                }
                                .frame(width: 110, height: 110)
                                .modifier(AchievementChoiceStyle(isSelected: selectedChoice == idx)) // <-- Apply here
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
                                HStack(spacing: 8) {
                                    TextField("", text: $numberInput)
                                        .keyboardType(.numberPad)
                                        .frame(width: 30)
                                        .padding(6)
                                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color("AccentPurple"), lineWidth: 1))
                                        .foregroundColor(.white)
                                        .font(.custom("Sora-Regular", size: 14))
                                    Picker("", selection: $timeRange) {
                                        ForEach(timeOptions, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .frame(width: 120)
                                    .padding(6)
                                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color("AccentPurple"), lineWidth: 1))
                                    .foregroundColor(.white)
                                }
                                .padding(.top, 4)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color("AccentPurple"), lineWidth: 2)
                            .background(Color.clear))
                            .padding(.horizontal, 8)
                            .padding(.top, 16)
                        }
                    }
                    Spacer()
                    NavigationLink(
                        destination: DevicesView(),
                        isActive: $navigateToDevices
                    ) {
                        Button(action: {
                            navigateToDevices = true
                        }) {
                            Text("Continue")
                                .font(.custom("Sora-SemiBold", size: 15))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 40)
                                .background(selectedChoice != nil && !numberInput.isEmpty ? Color("AccentPurple") : Color.gray.opacity(0.5))
                                .cornerRadius(32)
                        }
                        .disabled(selectedChoice == nil || numberInput.isEmpty)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    AchievementView()
        .background(Color.black)
}