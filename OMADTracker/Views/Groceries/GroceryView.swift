import SwiftUI

struct GroceryView: View {
    @StateObject private var vm = GroceryViewModel()
    @State private var showResetConfirm = false

    private var checkedCount: Int {
        GroceryData.allItemIDs.filter { vm.isChecked($0) }.count
    }
    private var totalCount: Int { GroceryData.allItemIDs.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 4) {
                    // Progress header
                    HStack {
                        Text("\(checkedCount) of \(totalCount) items")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(Double(checkedCount) / Double(totalCount) * 100))% done")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.primaryGreen)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Grocery sections
                    ForEach(GroceryData.sections) { section in
                        GrocerySectionView(section: section, vm: vm)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Groceries")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: vm.shareText()) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset List", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .confirmationDialog(
                "Reset grocery list?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset All", role: .destructive) {
                    withAnimation { vm.resetAll() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will uncheck all items for next week's shop.")
            }
        }
    }
}

#Preview {
    GroceryView()
}
