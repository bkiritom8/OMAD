import SwiftUI

struct GroceryItemRow: View {
    let item: GroceryItem
    let isChecked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isChecked ? Color.primaryGreen : Color.secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 1) {
                    Text(item.name)
                        .font(.subheadline)
                        .foregroundStyle(isChecked ? .secondary : .primary)
                        .strikethrough(isChecked, color: .secondary)
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
