import SwiftUI

struct FoodItemRow: View {
    let item: MealItem
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Checkmark
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isChecked ? Color.primaryGreen : Color.secondary)
                    .font(.title3)

                // Name + quantity
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(item.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        if item.isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.lockedPurple)
                        }
                    }
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Macros
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(item.calories)) kcal")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Text("\(Int(item.protein))g P")
                        Text("·")
                        Text("\(Int(item.fiber))g F")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                item.isLocked
                    ? Color.lockedPurple.opacity(0.08)
                    : Color(.secondarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 8) {
        FoodItemRow(
            item: MealItem(name: "Aldi California Medley", quantity: "340g steamed",
                           calories: 120, protein: 8, fiber: 12, isLocked: true),
            isChecked: false,
            onToggle: {}
        )
        FoodItemRow(
            item: MealItem(name: "Chicken Breast", quantity: "180g cooked",
                           calories: 297, protein: 56, fiber: 0, isLocked: false),
            isChecked: true,
            onToggle: {}
        )
    }
    .padding()
}
