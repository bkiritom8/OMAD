import SwiftUI
import Charts

struct WeightChart: View {
    let entries: [WeightEntry]
    var planStartDate: Date = Date()

    @AppStorage("startWeightKg") private var startWeightKg: Double = 82.0
    @AppStorage("goalWeightKg")  private var goalWeightKg: Double  = 79.0

    private var planEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 28, to: planStartDate) ?? planStartDate
    }

    var body: some View {
        if entries.count < 3 {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
                Text("Add more weigh-ins to see your chart")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(height: 220)
        } else {
            Chart {
                // Reference line: start weight
                RuleMark(y: .value("Start", startWeightKg))
                    .foregroundStyle(Color.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    .annotation(position: .leading, alignment: .center) {
                        Text(String(format: "%.0f", startWeightKg))
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }

                // Reference line: goal weight
                RuleMark(y: .value("Goal", goalWeightKg))
                    .foregroundStyle(Color.primaryGreen.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    .annotation(position: .leading, alignment: .center) {
                        Text(String(format: "%.0f", goalWeightKg))
                            .font(.caption2)
                            .foregroundStyle(Color.primaryGreen)
                    }

                // Projection line: start → goal over 28 days
                LineMark(
                    x: .value("Date", planStartDate, unit: .day),
                    y: .value("Weight", startWeightKg),
                    series: .value("Series", "projection")
                )
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

                LineMark(
                    x: .value("Date", planEndDate, unit: .day),
                    y: .value("Weight", goalWeightKg),
                    series: .value("Series", "projection")
                )
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))

                // Actual weight line + points
                ForEach(entries.sorted(by: { $0.date < $1.date })) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Weight", entry.weightKg),
                        series: .value("Series", "actual")
                    )
                    .foregroundStyle(Color.primaryGreen)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Weight", entry.weightKg)
                    )
                    .foregroundStyle(Color.primaryGreen)
                    .symbolSize(40)
                }
            }
            .chartYScale(domain: (goalWeightKg - 3)...(startWeightKg + 3))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: Date.FormatStyle().month(.abbreviated).day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let kg = value.as(Double.self) {
                            Text("\(Int(kg))kg")
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 220)
            .padding(.bottom, 40)
            .clipped()
        }
    }
}

#Preview {
    WeightChart(entries: [], planStartDate: Date())
        .padding()
}
