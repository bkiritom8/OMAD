import SwiftUI

struct MacroProgressCard: View {
    let label: String
    let logged: Double
    let target: Double
    let unit: String
    /// When true: bar turns red if over target and a hard-cap marker is shown at the limit.
    /// When false (protein / fiber): bar turns teal when target is met — over is fine.
    var isCalories: Bool = false

    private var progress: Double { min(logged / max(target, 1), 1.0) }

    private var barColor: Color {
        if isCalories {
            return logged >= target ? .red : Color.primaryGreen
        } else {
            return logged >= target ? .teal : Color.primaryGreen
        }
    }

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(logged))/\(Int(target))\(unit)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 8)

                    // Fill bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * animatedProgress, height: 8)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7),
                            value: animatedProgress
                        )

                    // Hard cap marker line at right edge (only for calorie card)
                    if isCalories {
                        HStack(spacing: 0) {
                            Spacer()
                            Rectangle()
                                .fill(Color.red.opacity(0.75))
                                .frame(width: 2, height: 12)
                        }
                    }
                }
            }
            .frame(height: 12)

            if isCalories {
                Text(logged > target
                     ? "\(Int(logged - target))\(unit) over limit"
                     : "\(Int(target - logged))\(unit) remaining")
                    .font(.caption2)
                    .foregroundStyle(logged >= target ? .red : barColor)
            } else {
                Text(logged >= target
                     ? "Target met ✓"
                     : "\(Int(target - logged))\(unit) to go")
                    .font(.caption2)
                    .foregroundStyle(barColor)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear { animatedProgress = progress }
        .onChange(of: logged) { _, _ in animatedProgress = progress }
    }
}

#Preview {
    VStack(spacing: 8) {
        HStack {
            MacroProgressCard(label: "CALORIES", logged: 1200, target: 1680, unit: " kcal", isCalories: true)
            MacroProgressCard(label: "PROTEIN", logged: 130, target: 153, unit: "g")
        }
        HStack {
            MacroProgressCard(label: "CALORIES", logged: 1720, target: 1680, unit: " kcal", isCalories: true)
            MacroProgressCard(label: "FIBER", logged: 20, target: 41, unit: "g")
        }
    }
    .padding()
}
