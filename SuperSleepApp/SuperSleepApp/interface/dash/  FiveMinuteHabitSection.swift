import SwiftUI

struct FiveMinuteHabitSection: View {
    var habit: String
    @State private var isCompleted = false
    @State private var isLoading = false

    var body: some View {
        HStack {
            Text("Your goal today!")
                .font(DashboardFonts.section)
                .foregroundColor(DashboardColors.accent)
            Spacer()
            Text(">")
                .font(DashboardFonts.section)
                .foregroundColor(DashboardColors.accent)
        }
        .padding(.horizontal, 16)
        HStack {
            Text(habit)
                .font(DashboardFonts.section)
                .foregroundColor(.white)
                .opacity(0.6)
            Spacer()
            if isCompleted {
                Text("Complete!")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .clipShape(Capsule())
            } else {
                Button(action: {
                    isLoading = true
                    AddCompletionService.addCompletion(
                        uuid: SessionManager.shared.uuid,
                        habit: habit
                    ) { result in
                        isLoading = false
                        if case .success = result {
                            isCompleted = true
                        }
                    }
                }) {
                    Text(isLoading ? "..." : "Complete")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.7))
                        .clipShape(Capsule())
                }
                .disabled(isLoading)
            }
        }
        .padding()
        .background(DashboardColors.card)
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}