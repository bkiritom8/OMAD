import SwiftUI
import SwiftData

struct FoodCheckerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var customFoods: [CustomFood]
    @Query private var allFoodLogs: [FoodLog]

    @StateObject private var vm = FoodCheckerViewModel()
    @State private var showCustomFoodSheet = false
    @State private var showOverBudgetAlert = false

    private let calorieHardCap: Double = 1300
    private let softWarnThreshold: Double = 1250

    private var todayLogs: [FoodLog] {
        let today = Date().startOfDay
        return allFoodLogs.filter { $0.date >= today && $0.date < today.endOfDay }
    }

    private var todayCaloriesLogged: Double { todayLogs.reduce(0) { $0 + $1.calories } }
    private var remainingCalories: Double   { max(0, calorieHardCap - todayCaloriesLogged) }
    private var remainingProtein: Double    { max(0, 125 - todayLogs.reduce(0) { $0 + $1.protein }) }
    private var remainingFiber: Double      { max(0, 42  - todayLogs.reduce(0) { $0 + $1.fiber }) }

    private var projectedCalories: Double { todayCaloriesLogged + vm.calculatedCalories }
    private var caloriesOver: Double      { max(0, projectedCalories - calorieHardCap) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search 60+ foods...", text: $vm.searchQuery)
                        .autocorrectionDisabled()
                    if !vm.searchQuery.isEmpty {
                        Button { vm.searchQuery = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))

                if vm.hasSelection {
                    selectedFoodPane
                } else {
                    List(vm.filteredFoods(allFoods: FoodDatabase.allFoods, customFoods: customFoods)) { food in
                        FoodSearchRow(food: food)
                            .onTapGesture {
                                withAnimation { vm.selectFood(food) }
                            }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Food Checker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCustomFoodSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $showCustomFoodSheet) {
                AddCustomFoodSheet()
            }
            .background(Color(.systemGroupedBackground))
            .animation(.default, value: vm.hasSelection)
            .alert("Over Calorie Limit", isPresented: $showOverBudgetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Add Anyway", role: .destructive) {
                    vm.addToToday(modelContext: modelContext)
                }
            } message: {
                Text("Adding \(vm.selectedFood?.name ?? "this food") would take you to \(Int(projectedCalories)) kcal — \(Int(caloriesOver)) kcal over your 1300 limit.")
            }
        }
    }

    @ViewBuilder
    private var selectedFoodPane: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Food header + clear
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vm.selectedFood?.name ?? "")
                            .font(.headline)
                        if let food = vm.selectedFood {
                            Text("\(Int(food.caloriesPer100g)) kcal · \(Int(food.proteinPer100g))g P · \(Int(food.fiberPer100g))g F \(vm.perUnitLabel)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Button {
                        withAnimation { vm.clearSelection() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // Quantity + unit picker
                HStack(spacing: 12) {
                    TextField("Qty", value: $vm.quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 90)

                    Picker("Unit", selection: $vm.selectedUnit) {
                        Text("g").tag("g")
                        Text("ml").tag("ml")
                        Text("pcs").tag("pieces")
                        Text("cups").tag("cups")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                // Remaining budget display (live)
                let remaining = calorieHardCap - todayCaloriesLogged - vm.calculatedCalories
                HStack {
                    Image(systemName: remaining < 0 ? "xmark.circle.fill" : "gauge.medium")
                        .foregroundStyle(remaining < 0 ? .red : remaining < 100 ? .orange : .secondary)
                    Text(remaining < 0
                         ? "\(Int(-remaining)) kcal over if added"
                         : "\(Int(remaining)) kcal remaining after adding")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(remaining < 0 ? .red : remaining < 100 ? .orange : .secondary)
                    Spacer()
                }
                .padding(.horizontal)

                // Macro chips (live)
                HStack(spacing: 12) {
                    macroChip(value: Int(vm.calculatedCalories), label: "kcal")
                    macroChip(value: Int(vm.calculatedProtein), label: "protein")
                    macroChip(value: Int(vm.calculatedFiber), label: "fiber")
                }
                .padding(.horizontal)

                // Budget verdict
                MacroBudgetView(
                    calculatedCalories: vm.calculatedCalories,
                    calculatedProtein: vm.calculatedProtein,
                    calculatedFiber: vm.calculatedFiber,
                    remainingCalories: remainingCalories,
                    remainingProtein: remainingProtein,
                    remainingFiber: remainingFiber
                )
                .padding(.horizontal)

                // Soft warning (1250–1300 range)
                if projectedCalories >= softWarnThreshold && projectedCalories <= calorieHardCap {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.orange)
                        Text("This will use most of your remaining \(Int(remainingCalories)) kcal budget")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.orange)
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                // Add to today
                Button {
                    if projectedCalories > calorieHardCap {
                        showOverBudgetAlert = true
                    } else {
                        vm.addToToday(modelContext: modelContext)
                    }
                } label: {
                    Label("Add to Today", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(projectedCalories > calorieHardCap ? Color.red : Color.primaryGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func macroChip(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.primaryGreen)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FoodCheckerView()
        .modelContainer(for: [CustomFood.self, FoodLog.self], inMemory: true)
}
