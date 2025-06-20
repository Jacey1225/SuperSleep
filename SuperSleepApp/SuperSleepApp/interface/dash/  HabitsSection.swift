import SwiftUI

struct HabitsSection: View {
    @Binding var habits: [(name: String, progress: Int, total: Int)]
    @State private var isLoading = true
    var onArrowTap: () -> Void = {}
    var onHabitCompleted: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Habits Progress")
                    .font(DashboardFonts.section)
                    .foregroundColor(DashboardColors.accent)
                Spacer()
                Button(action: onArrowTap) {
                    Text(">")
                        .font(DashboardFonts.section)
                        .foregroundColor(DashboardColors.accent)
                }
            }
            .padding(.horizontal, 16)
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                ForEach(habits, id: \.name) { habit in
                    HabitRowView(
                        habit: habit.name,
                        progress: "\(habit.progress)/\(habit.total) completed",
                        onComplete: {
                            AddCompletionService.addCompletion(
                                uuid: SessionManager.shared.uuid,
                                habit: habit.name
                            ) { result in
                                if case .success = result {
                                    onHabitCompleted()
                                }
                            }
                        }
                    )
                }
            }
        }
        .background(DashboardColors.card)
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .onAppear {
            GetHabitsService.getMicroHabits(uuid: SessionManager.shared.uuid) { result in
                switch result {
                case .success(let habitsDict):
                    self.habits = habitsDict.map { (key, value) in
                        (name: key, progress: value[0], total: value[1])
                    }
                    .sorted { $0.name < $1.name }
                    self.isLoading = false
                case .failure:
                    self.habits = []
                    self.isLoading = false
                }
            }
        }
    }
}