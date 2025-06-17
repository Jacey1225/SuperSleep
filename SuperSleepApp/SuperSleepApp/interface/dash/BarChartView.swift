import SwiftUI

struct BarChartView: View {
    let values: [CGFloat]
    let days: [String]
    var body: some View {
        GeometryReader { geometry in
            let barCount = values.count
            let spacing: CGFloat = 10
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidth = (geometry.size.width - totalSpacing) / CGFloat(barCount)
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { i in
                    BarChartBar(value: values[i], day: days[i], index: i, width: barWidth)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
        }
    }
}

private struct BarChartBar: View {
    let value: CGFloat
    let day: String
    let index: Int
    let width: CGFloat

    var fillStyle: LinearGradient {
        if value >= 50 {
            return DashboardColors.barHealthy
        } else {
            // Wrap the color in a gradient for type consistency
            return LinearGradient(
                gradient: Gradient(colors: [DashboardColors.barUnhealthy, DashboardColors.barUnhealthy]),
                startPoint: .bottom, endPoint: .top
            )
        }
    }

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(fillStyle)
                .frame(width: width, height: max(5, value))
                .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: value)
            Text(day)
                .font(.system(size: 12))
                .foregroundColor(Color(red: 187/255, green: 187/255, blue: 187/255))
        }
    }
}