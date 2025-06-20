import SwiftUI

struct HabitTrackView: View {
    let habit: String
    let current: Int
    let total: Int
    var isCompleted: Bool
    var onComplete: () -> Void

    var percent: CGFloat {
        total > 0 ? CGFloat(current) / CGFloat(total) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("sprofile")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                Text(habit)
                    .font(.custom("Sora-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .padding(.leading, 8)
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
                    Button(action: onComplete) {
                        Text("Complete")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.7))
                            .clipShape(Capsule())
                    }
                }
            }
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 58/255, green: 63/255, blue: 75/255))
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#7C6FF0"))
                    .frame(width: percent * UIScreen.main.bounds.width * 0.7, height: 8)
                    .animation(.easeInOut(duration: 0.4), value: percent)
            }
            // Progress label
            HStack {
                Spacer()
                Text("\(current)/\(total)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color(red: 43/255, green: 61/255, blue: 79/255).opacity(0.4))
        .cornerRadius(10)
    }
}