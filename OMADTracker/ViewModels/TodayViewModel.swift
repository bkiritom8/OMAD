import Foundation
import SwiftData

class TodayViewModel: ObservableObject {
    // MARK: - Targets
    let calorieTarget: Double = 1680
    let proteinTarget: Double = 153
    let fiberTarget: Double   = 41
    let waterTargetMl: Int    = 2500

    // MARK: - State
    @Published var checkedMealItemIDs: Set<String> = []

    private var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "checkedItems_\(formatter.string(from: Date()))"
    }

    init() {
        loadCheckedItems()
    }

    // MARK: - Persistence
    func loadCheckedItems() {
        if let stored = UserDefaults.standard.array(forKey: todayKey) as? [String] {
            checkedMealItemIDs = Set(stored)
        } else {
            checkedMealItemIDs = []
        }
    }

    func saveCheckedItems() {
        UserDefaults.standard.set(Array(checkedMealItemIDs), forKey: todayKey)
    }

    // MARK: - Toggle meal plan item
    func toggleMealItem(named name: String, item: MealItem, modelContext: ModelContext) {
        if checkedMealItemIDs.contains(name) {
            checkedMealItemIDs.remove(name)
            // Delete today's FoodLog entries for this meal plan item
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let descriptor = FetchDescriptor<FoodLog>(
                predicate: #Predicate { log in
                    log.foodName == name &&
                    log.isFromMealPlan == true &&
                    log.date >= today &&
                    log.date < tomorrow
                }
            )
            if let logs = try? modelContext.fetch(descriptor) {
                for log in logs { modelContext.delete(log) }
            }
        } else {
            checkedMealItemIDs.insert(name)
            let entry = FoodLog(
                date: Date(),
                foodName: item.name,
                quantity: 1,
                unit: "serving",
                calories: item.calories,
                protein: item.protein,
                fiber: item.fiber,
                isFromMealPlan: true
            )
            modelContext.insert(entry)
        }
        saveCheckedItems()
        try? modelContext.save()
    }

    // MARK: - Water
    func addWater(_ ml: Int, existingEntry: WaterEntry?, modelContext: ModelContext) {
        if let entry = existingEntry {
            entry.totalMl += ml
        } else {
            let entry = WaterEntry(date: Date().startOfDay, totalMl: ml)
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }

    func waterToday(from entries: [WaterEntry]) -> Int {
        let today = Date().startOfDay
        return entries.first(where: { $0.date >= today && $0.date < today.endOfDay })?.totalMl ?? 0
    }
}
