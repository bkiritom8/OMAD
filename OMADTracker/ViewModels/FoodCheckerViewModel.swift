import Foundation
import SwiftData

class FoodCheckerViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var selectedFood: FoodItem?
    @Published var selectedCustomFood: CustomFood?
    @Published var quantity: Double = 100
    @Published var selectedUnit: String = "g"

    // MARK: - Computed macros

    private var multiplier: Double {
        switch selectedUnit {
        case "g", "ml": return quantity / 100.0
        case "pieces":  return quantity * (selectedFood?.gramsPerPiece ?? 100.0) / 100.0
        case "cups":    return quantity * 2.4   // 1 cup ≈ 240g
        default:        return quantity / 100.0
        }
    }

    /// "per piece" for count-based foods, "per 100g" for everything else
    var perUnitLabel: String {
        selectedFood?.defaultUnit == "pieces" ? "per piece" : "per 100g"
    }

    var calculatedCalories: Double {
        let per100 = selectedFood?.caloriesPer100g ?? selectedCustomFood?.caloriesPer100g ?? 0
        return per100 * multiplier
    }

    var calculatedProtein: Double {
        let per100 = selectedFood?.proteinPer100g ?? selectedCustomFood?.proteinPer100g ?? 0
        return per100 * multiplier
    }

    var calculatedFiber: Double {
        let per100 = selectedFood?.fiberPer100g ?? selectedCustomFood?.fiberPer100g ?? 0
        return per100 * multiplier
    }

    var hasSelection: Bool {
        selectedFood != nil || selectedCustomFood != nil
    }

    // MARK: - Search / Filter

    func filteredFoods(allFoods: [FoodItem], customFoods: [CustomFood]) -> [FoodItem] {
        let customAsFood = customFoods.map { custom in
            FoodItem(
                name: custom.name + " (custom)",
                caloriesPer100g: custom.caloriesPer100g,
                proteinPer100g: custom.proteinPer100g,
                fiberPer100g: custom.fiberPer100g,
                category: "Custom"
            )
        }
        let combined = allFoods + customAsFood
        if searchQuery.isEmpty { return combined }
        return combined.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    // MARK: - Budget verdict

    func verdict(
        remainingCalories: Double,
        remainingProtein: Double,
        remainingFiber: Double
    ) -> (fits: Bool, overItems: [String]) {
        var overItems: [String] = []
        if calculatedCalories > remainingCalories + 1 {
            overItems.append("Calories (over by \(Int(calculatedCalories - remainingCalories)) kcal)")
        }
        if calculatedProtein > remainingProtein + 0.5 {
            overItems.append("Protein (over by \(String(format: "%.1f", calculatedProtein - remainingProtein))g)")
        }
        // Note: fiber going over target is not a problem — we just note it
        return (fits: overItems.isEmpty, overItems: overItems)
    }

    // MARK: - Add to today

    func addToToday(modelContext: ModelContext) {
        let name = selectedFood?.name ?? selectedCustomFood?.name ?? "Unknown"
        let entry = FoodLog(
            date: Date(),
            foodName: name,
            quantity: quantity,
            unit: selectedUnit,
            calories: calculatedCalories,
            protein: calculatedProtein,
            fiber: calculatedFiber,
            isFromMealPlan: false
        )
        modelContext.insert(entry)
        try? modelContext.save()
        clearSelection()
    }

    func selectFood(_ food: FoodItem) {
        selectedFood = food
        selectedUnit = food.defaultUnit
        quantity     = food.defaultUnit == "pieces" ? 1 : 100
    }

    func clearSelection() {
        selectedFood       = nil
        selectedCustomFood = nil
        quantity           = 100
        selectedUnit       = "g"
    }
}
