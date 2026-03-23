import SwiftUI
import SwiftData

struct TodayView: View {
    @EnvironmentObject var fastingManager: FastingManager
    @Environment(\.modelContext) private var modelContext

    @StateObject private var vm = TodayViewModel()

    // FoodLog entries for today
    @Query private var allFoodLogs: [FoodLog]
    // WaterEntry for today
    @Query private var allWaterEntries: [WaterEntry]

    @State private var showAddFood    = false
    @State private var showSettings   = false
    @State private var showFastDetail = false

    private var todaysMealDay: MealDay { MealPlanData.todaysMealDay() }

    private var todayFoodLogs: [FoodLog] {
        let today = Date().startOfDay
        return allFoodLogs.filter { $0.date >= today && $0.date < today.endOfDay }
    }
    private var todayWaterEntry: WaterEntry? {
        let today = Date().startOfDay
        return allWaterEntries.first(where: { $0.date >= today && $0.date < today.endOfDay })
    }

    private var loggedCalories: Double { todayFoodLogs.reduce(0) { $0 + $1.calories } }
    private var loggedProtein:  Double { todayFoodLogs.reduce(0) { $0 + $1.protein } }
    private var loggedFiber:    Double { todayFoodLogs.reduce(0) { $0 + $1.fiber } }
    private var waterToday:     Int    { todayWaterEntry?.totalMl ?? 0 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    headerSection

                    // Fasting banner
                    fastingBanner
                        .onTapGesture { showFastDetail = true }

                    // Calorie limit warning
                    calorieLimitBanner

                    // Fiber tip (when below threshold)
                    fiberTipBanner

                    // Macro cards
                    macroCardsSection

                    // Today's meal list
                    mealSection

                    // Add food button
                    Button {
                        showAddFood = true
                    } label: {
                        Label("Add Food", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primaryGreen.opacity(0.12))
                            .foregroundStyle(Color.primaryGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    // Water widget
                    waterWidget
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showAddFood) {
                AddFoodSheet()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showFastDetail) {
                fastingDetailSheet
            }
        }
        .onAppear { vm.loadCheckedItems() }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date().displayDayName)
                    .font(.title2.weight(.bold))
                Text(Date().displayDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            // Day's meal title
            Text(todaysMealDay.title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 140)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var fastingBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: fastingManager.isFasting ? "timer" : "moon.zzz.fill")
                .font(.title2)
                .foregroundStyle(fastingManager.fastingColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(fastingManager.isFasting ? "Fasting — \(fastingManager.elapsedString)" : "Not fasting")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(fastingManager.fastingColor)
                Text(fastingManager.eatingWindowMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    @ViewBuilder
    private var calorieLimitBanner: some View {
        let limit = Int(vm.calorieTarget)
        if loggedCalories > vm.calorieTarget {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)
                Text("Over \(limit) kcal limit — \(Int(loggedCalories - vm.calorieTarget)) kcal over")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(12)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        } else if loggedCalories >= vm.calorieTarget - 100 {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.white)
                Text("Almost at \(limit) kcal limit — \(Int(vm.calorieTarget - loggedCalories)) kcal left")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(12)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var fiberTipBanner: some View {
        if loggedFiber < 38 {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fiber tip")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                    Text("Your oats + chia + Aldi bag cover 21g automatically. If you're short, check that you've had the full legume portion today.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.green.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
        }
    }

    private var macroCardsSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                MacroProgressCard(
                    label: "CALORIES",
                    logged: loggedCalories,
                    target: vm.calorieTarget,
                    unit: " kcal",
                    isCalories: true
                )
                MacroProgressCard(
                    label: "PROTEIN",
                    logged: loggedProtein,
                    target: vm.proteinTarget,
                    unit: "g"
                )
            }
            MacroProgressCard(
                label: "FIBER",
                logged: loggedFiber,
                target: vm.fiberTarget,
                unit: "g"
            )
        }
        .padding(.horizontal)
    }

    private var extraFoodLogs: [FoodLog] {
        todayFoodLogs.filter { !$0.isFromMealPlan }
    }

    private var mealSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Meal")
                .font(.headline)
                .padding(.horizontal)

            // Meal plan items (checkable)
            ForEach(todaysMealDay.items) { item in
                FoodItemRow(
                    item: item,
                    isChecked: vm.checkedMealItemIDs.contains(item.name),
                    onToggle: {
                        withAnimation {
                            vm.toggleMealItem(named: item.name, item: item, modelContext: modelContext)
                        }
                    }
                )
                .padding(.horizontal)
            }

            // Extra food logged via Add Food
            ForEach(extraFoodLogs) { log in
                loggedFoodRow(log)
                    .padding(.horizontal)
            }
        }
    }

    private func loggedFoodRow(_ log: FoodLog) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(Color.primaryGreen)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.foodName)
                    .font(.subheadline.weight(.medium))
                Text("\(Int(log.quantity)) \(log.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(log.calories)) kcal")
                    .font(.caption.weight(.semibold))
                HStack(spacing: 4) {
                    Text("\(Int(log.protein))g P")
                    Text("·")
                    Text("\(Int(log.fiber))g F")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Button {
                modelContext.delete(log)
                try? modelContext.save()
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var waterWidget: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Water", systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
                Text("\(waterToday) / \(vm.waterTargetMl) ml")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.15))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue)
                        .frame(width: geo.size.width * min(Double(waterToday) / Double(vm.waterTargetMl), 1.0))
                        .animation(.spring(response: 0.5), value: waterToday)
                }
            }
            .frame(height: 10)

            // Quick add buttons
            HStack(spacing: 10) {
                Button {
                    vm.addWater(250, existingEntry: todayWaterEntry, modelContext: modelContext)
                } label: {
                    Label("+250 ml", systemImage: "plus")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.12))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }

                Button {
                    // 8 fl oz = 237 ml
                    vm.addWater(237, existingEntry: todayWaterEntry, modelContext: modelContext)
                } label: {
                    Label("+8 fl oz", systemImage: "plus")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.12))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }

    private var fastingDetailSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                CircularProgressRing(
                    progress: fastingManager.progressFraction,
                    color: fastingManager.fastingColor,
                    lineWidth: 22,
                    size: 220
                ) {
                    VStack(spacing: 4) {
                        Text(fastingManager.elapsedString)
                            .font(.system(size: 42, weight: .bold, design: .monospaced))
                            .foregroundStyle(fastingManager.fastingColor)
                        Text(fastingManager.isFasting ? "fasting" : "not fasting")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(fastingManager.eatingWindowMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    if fastingManager.isFasting {
                        fastingManager.breakFast(modelContext: modelContext)
                    } else {
                        fastingManager.startFast()
                    }
                } label: {
                    Text(fastingManager.isFasting ? "Break Fast" : "Start Fast")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(fastingManager.isFasting ? Color.red : Color.primaryGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .navigationTitle("Fasting Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showFastDetail = false }
                }
            }
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(FastingManager())
        .modelContainer(for: [FoodLog.self, WaterEntry.self], inMemory: true)
}
