import SwiftUI

struct MacroBudgetView: View {
    let calculatedCalories: Double
    let calculatedProtein: Double
    let calculatedFiber: Double
    let remainingCalories: Double
    let remainingProtein: Double
    let remainingFiber: Double

    private var fits: Bool {
        calculatedCalories <= remainingCalories + 1 &&
        calculatedProtein  <= remainingProtein  + 0.5
    }

    var body: some View {
        VStack(spacing: 10) {
            // Verdict badge
            HStack {
                Image(systemName: fits ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                Text(fits ? "FITS your budget" : "OVER budget")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(fits ? Color.primaryGreen : .red)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background((fits ? Color.primaryGreen : Color.red).opacity(0.12))
            .clipShape(Capsule())

            // Budget rows
            VStack(spacing: 6) {
                budgetRow(
                    label: "Calories",
                    adding: Int(calculatedCalories),
                    remaining: Int(remainingCalories),
                    unit: "kcal"
                )
                budgetRow(
                    label: "Protein",
                    adding: Int(calculatedProtein),
                    remaining: Int(remainingProtein),
                    unit: "g"
                )
                budgetRow(
                    label: "Fiber",
                    adding: Int(calculatedFiber),
                    remaining: Int(remainingFiber),
                    unit: "g"
                )
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func budgetRow(label: String, adding: Int, remaining: Int, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text("+\(adding)\(unit)")
                .font(.caption.weight(.semibold))
            Text("·")
                .foregroundStyle(.secondary)
            Text("\(remaining)\(unit) left")
                .font(.caption)
                .foregroundStyle(adding > remaining ? .red : Color.primaryGreen)
        }
    }
}
