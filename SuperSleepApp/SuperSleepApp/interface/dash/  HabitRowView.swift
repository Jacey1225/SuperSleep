import SwiftUI

struct HabitRowView: View {
    let habit: String
    let progress: String
    var onComplete: () -> Void = {}

    @State private var isCompleted = false
    @State private var isLoading = false

    var body: some View {
        HStack {
            Image("habit")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(DashboardColors.accent)
            Text(habit)
                .font(DashboardFonts.section)
                .foregroundColor(.white)
                .padding(.leading, 8)
            Spacer()
            Text(progress)
                .font(DashboardFonts.body)
                .foregroundColor(.white)
                .opacity(0.7)
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
                    onComplete()
                    isCompleted = true
                    isLoading = false
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
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
    }
}