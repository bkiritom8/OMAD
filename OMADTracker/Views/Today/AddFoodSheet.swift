import SwiftUI
import SwiftData

struct AddFoodSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var customFoods: [CustomFood]
    @Query private var allFoodLogs: [FoodLog]

    @StateObject private var vm = FoodCheckerViewModel()
    @State private var showCustomFoodForm = false
    @State private var showOverBudgetAlert = false

    private let calorieHardCap: Double = 1300

    private var todayCaloriesLogged: Double {
        let today = Date().startOfDay
        return allFoodLogs
            .filter { $0.date >= today && $0.date < today.endOfDay }
            .reduce(0) { $0 + $1.calories }
    }

    private var projectedCalories: Double { todayCaloriesLogged + vm.calculatedCalories }
    private var remainingAfterAdd: Double  { calorieHardCap - projectedCalories }
    private var caloriesOver: Double       { max(0, projectedCalories - calorieHardCap) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search foods...", text: $vm.searchQuery)
                        .autocorrectionDisabled()
                }
                .padding(10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.top, 8)

                if vm.hasSelection {
                    selectedFoodSection
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else {
                    List {
                        ForEach(vm.filteredFoods(allFoods: FoodDatabase.allFoods, customFoods: customFoods)) { food in
                            Button {
                                withAnimation { vm.selectFood(food) }
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(food.name)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(Int(food.caloriesPer100g)) kcal · \(Int(food.proteinPer100g))g P · \(Int(food.fiberPer100g))g F \(food.defaultUnit == "pieces" ? "per piece" : "per 100g")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Custom") { showCustomFoodForm = true }
                        .font(.caption)
                }
            }
            .sheet(isPresented: $showCustomFoodForm) {
                AddCustomFoodSheet()
            }
            .animation(.default, value: vm.hasSelection)
            .alert("Over Calorie Limit", isPresented: $showOverBudgetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Add Anyway", role: .destructive) {
                    vm.addToToday(modelContext: modelContext)
                    dismiss()
                }
            } message: {
                Text("Adding \(vm.selectedFood?.name ?? "this food") would take you to \(Int(projectedCalories)) kcal — \(Int(caloriesOver)) kcal over your 1300 limit.")
            }
        }
    }

    @ViewBuilder
    private var selectedFoodSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Selected food header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.selectedFood?.name ?? "Custom food")
                            .font(.headline)
                        Text("\(vm.perUnitLabel): \(Int(vm.selectedFood?.caloriesPer100g ?? 0)) kcal · \(Int(vm.selectedFood?.proteinPer100g ?? 0))g P · \(Int(vm.selectedFood?.fiberPer100g ?? 0))g F")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        withAnimation { vm.clearSelection() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // Quantity + unit
                HStack(spacing: 12) {
                    TextField("Quantity", value: $vm.quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)

                    Picker("Unit", selection: $vm.selectedUnit) {
                        Text("g").tag("g")
                        Text("ml").tag("ml")
                        Text("pieces").tag("pieces")
                        Text("cups").tag("cups")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                // Calculated macros preview
                HStack(spacing: 16) {
                    macroChip(value: Int(vm.calculatedCalories), label: "kcal")
                    macroChip(value: Int(vm.calculatedProtein), label: "protein")
                    macroChip(value: Int(vm.calculatedFiber), label: "fiber")
                }
                .padding(.horizontal)

                // Live remaining budget
                HStack {
                    Image(systemName: remainingAfterAdd < 0 ? "xmark.circle.fill" : "gauge.medium")
                        .foregroundStyle(budgetColor)
                    Text(remainingAfterAdd < 0
                         ? "\(Int(-remainingAfterAdd)) kcal over limit after adding"
                         : "\(Int(remainingAfterAdd)) kcal remaining after adding")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(budgetColor)
                    Spacer()
                }
                .padding(.horizontal)

                // Add to today button
                Button {
                    if projectedCalories > calorieHardCap {
                        showOverBudgetAlert = true
                    } else {
                        vm.addToToday(modelContext: modelContext)
                        dismiss()
                    }
                } label: {
                    Label("Add to Today", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(projectedCalories > calorieHardCap ? Color.red : Color.primaryGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var budgetColor: Color {
        if remainingAfterAdd < 0 { return .red }
        if remainingAfterAdd < 100 { return .orange }
        return .secondary
    }

    private func macroChip(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.primaryGreen)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
