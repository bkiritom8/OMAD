import Foundation
import SwiftData

@Model
final class WeightEntry {
    var date: Date
    var weightKg: Double

    init(date: Date, weightKg: Double) {
        self.date = date
        self.weightKg = weightKg
    }
}

@Model
final class WaterEntry {
    var date: Date
    var totalMl: Int

    init(date: Date, totalMl: Int) {
        self.date = date
        self.totalMl = totalMl
    }
}

@Model
final class ExerciseEntry {
    var date: Date
    var type: String
    var durationMinutes: Int
    var caloriesBurned: Int
    var notes: String

    init(date: Date, type: String, durationMinutes: Int, caloriesBurned: Int, notes: String) {
        self.date = date
        self.type = type
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.notes = notes
    }
}

@Model
final class FastEntry {
    var startTime: Date
    var endTime: Date?
    var durationHours: Double

    init(startTime: Date, endTime: Date? = nil, durationHours: Double) {
        self.startTime = startTime
        self.endTime = endTime
        self.durationHours = durationHours
    }
}

@Model
final class CustomFood {
    var name: String
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var fiberPer100g: Double

    init(name: String, caloriesPer100g: Double, proteinPer100g: Double, fiberPer100g: Double) {
        self.name = name
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.fiberPer100g = fiberPer100g
    }
}

@Model
final class FoodLog {
    var date: Date
    var foodName: String
    var quantity: Double
    var unit: String
    var calories: Double
    var protein: Double
    var fiber: Double
    var isFromMealPlan: Bool

    init(date: Date, foodName: String, quantity: Double, unit: String,
         calories: Double, protein: Double, fiber: Double, isFromMealPlan: Bool) {
        self.date = date
        self.foodName = foodName
        self.quantity = quantity
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.fiber = fiber
        self.isFromMealPlan = isFromMealPlan
    }
}
