import SwiftUI

struct HabitsView: View {
    @State private var habits: [(name: String, current: Int, total: Int)] = []
    @State private var isLoading = true
    @State private var completedHabits: Set<String> = []

    let streak = 4
    let streakTotal = 7

    var onHomeTap: () -> Void = {}

    func loadHabits() {
        isLoading = true
        GetHabitsService.getMicroHabits(uuid: SessionManager.shared.uuid) { result in
            switch result {
            case .success(let habitsDict):
                self.habits = habitsDict.map { (key, value) in
                    (name: key, current: value[0], total: value[1])
                }
                .sorted { $0.name < $1.name }
                self.isLoading = false
            case .failure:
                self.habits = []
                self.isLoading = false
            }
        }
    }

    var body: some View {
        ZStack {
            BreathingBackground()
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("<  Settings")
                        .foregroundColor(Color(hex: "#A6ABFB"))
                        .font(.custom("Sora", size: 16))
                        .padding(.leading, 16)
                    Spacer()
                    Image("habit")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .padding(.trailing, 16)
                }
                .padding(.top, 32)
                .padding(.bottom, 8)
                Divider().background(Color(red: 41/255, green: 48/255, blue: 53/255))

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Habits")
                                .font(.custom("Sora-Bold", size: 22))
                                .foregroundColor(.white)
                            Text("Small changes, big results")
                                .font(.custom("Sora-Regular", size: 14))
                                .foregroundColor(Color(hex: "#A5BED4"))
                                .opacity(0.8)
                        }
                        .padding(.leading, 16)
                        .padding(.top, 16)

                        ProgressCircle(current: habits.reduce(0) { $0 + $1.current },
                                       total: habits.reduce(0) { $0 + $1.total })

                        Text("Your progress today")
                            .font(.custom("Sora-SemiBold", size: 16))
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)

                        HStack(spacing: 24) {
                            Text("Today")
                                .font(.custom("Sora-SemiBold", size: 15))
                                .foregroundColor(.white)
                                .underline()
                            Text("This week")
                                .font(.custom("Sora-SemiBold", size: 15))
                                .foregroundColor(.white.opacity(0.8))
                            Text("Completed")
                                .font(.custom("Sora-SemiBold", size: 15))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 4)

                        VStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .padding()
                            } else {
                                ForEach(habits, id: \.name) { habit in
                                    HabitTrackView(
                                        habit: habit.name,
                                        current: habit.current,
                                        total: habit.total,
                                        isCompleted: completedHabits.contains(habit.name),
                                        onComplete: {
                                            AddCompletionService.addCompletion(
                                                uuid: SessionManager.shared.uuid,
                                                habit: habit.name
                                            ) { result in
                                                if case .success = result {
                                                    completedHabits.insert(habit.name)
                                                    loadHabits() 
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)

                        Text("Your current streak")
                            .font(.custom("Sora-SemiBold", size: 15))
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .padding(.leading, 16)
                            .padding(.top, 16)

                        HStack(spacing: 8) {
                            ForEach(1...streakTotal, id: \.self) { i in
                                Text("\(i)")
                                    .font(.custom("Sora-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(i <= streak ? Color(hex: "#7C6FF0") : Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.vertical, 8)
                    }
                }
                .onAppear {
                    loadHabits()
                }

                Divider().background(Color(red: 41/255, green: 48/255, blue: 53/255))
                DashboardFooterSection(
                    onHomeTap: onHomeTap
                )
            }
        }
    }
}