import SwiftUI

struct MealFoodCard: View {
    let item: MealItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.name)
                            .font(.subheadline.weight(.semibold))
                        if item.isLocked {
                            Text("LOCKED")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.lockedPurple)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if !item.note.isEmpty {
                        Text(item.note)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                }
                Spacer()
            }

            HStack(spacing: 0) {
                macroLabel(value: Int(item.calories), label: "kcal", primary: true)
                Divider().frame(height: 24).padding(.horizontal, 8)
                macroLabel(value: Int(item.protein), label: "g protein", primary: false)
                Divider().frame(height: 24).padding(.horizontal, 8)
                macroLabel(value: Int(item.fiber), label: "g fiber", primary: false)
                Spacer()
            }
        }
        .padding(12)
        .background(item.isLocked
            ? Color.lockedPurple.opacity(0.07)
            : Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func macroLabel(value: Int, label: String, primary: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(value)")
                .font(primary ? .subheadline.weight(.bold) : .subheadline.weight(.medium))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
