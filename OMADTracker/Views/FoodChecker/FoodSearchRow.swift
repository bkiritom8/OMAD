import SwiftUI

struct FoodSearchRow: View {
    let food: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(food.name)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(food.category)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(Capsule())
                    .foregroundStyle(.secondary)
            }
            Text("\(Int(food.caloriesPer100g)) kcal · \(Int(food.proteinPer100g))g protein · \(Int(food.fiberPer100g))g fiber \(food.defaultUnit == "pieces" ? "per piece" : "per 100g")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}
