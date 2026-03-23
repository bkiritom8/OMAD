import SwiftUI
import Charts

private let flOzToMl: Double = 29.5735

struct WaterChart: View {
    let entries: [WaterEntry]  // all water entries; view filters to last 7 days
    var useFlOz: Bool = false

    private let goalMl = 2500

    private var last7Days: [(date: Date, ml: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let ml = entries.first(where: { calendar.isDate($0.date, inSameDayAs: day) })?.totalMl ?? 0
            return (date: day, ml: ml)
        }
    }

    private func displayValue(_ ml: Int) -> Double {
        useFlOz ? Double(ml) / flOzToMl : Double(ml)
    }

    private var goalDisplay: Double {
        useFlOz ? Double(goalMl) / flOzToMl : Double(goalMl)
    }

    private var yScaleMax: Double {
        useFlOz ? Double(3500) / flOzToMl : Double(3500)
    }

    var body: some View {
        Chart(last7Days, id: \.date) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value(useFlOz ? "Water (fl oz)" : "Water (ml)", displayValue(day.ml))
            )
            .foregroundStyle(day.ml >= goalMl
                ? Color.primaryGreen
                : Color.primaryGreen.opacity(0.45))
            .cornerRadius(4)

            RuleMark(y: .value("Goal", goalDisplay))
                .foregroundStyle(Color.primaryGreen.opacity(0.4))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let val = value.as(Double.self) {
                        if useFlOz {
                            Text("\(Int(val.rounded()))oz")
                                .font(.caption2)
                        } else {
                            let ml = Int(val)
                            Text(ml >= 1000 ? "\(ml / 1000)L" : "\(ml)")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        .chartYScale(domain: 0...yScaleMax)
        .frame(height: 150)
    }
}

#Preview {
    WaterChart(entries: [])
        .padding()
}
