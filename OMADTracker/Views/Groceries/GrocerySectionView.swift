import SwiftUI

struct GrocerySectionView: View {
    let section: GrocerySection
    @ObservedObject var vm: GroceryViewModel

    // Show unchecked items first, then checked
    private var sortedItems: [GroceryItem] {
        let unchecked = section.items.filter { !vm.isChecked($0.id) }
        let checked   = section.items.filter {  vm.isChecked($0.id) }
        return unchecked + checked
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(section.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)
                .padding(.top, 8)

            VStack(spacing: 0) {
                ForEach(sortedItems) { item in
                    GroceryItemRow(
                        item: item,
                        isChecked: vm.isChecked(item.id),
                        onToggle: { withAnimation { vm.toggle(itemID: item.id) } }
                    )
                    .padding(.horizontal, 12)
                    if item.id != sortedItems.last?.id {
                        Divider().padding(.leading, 44)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
