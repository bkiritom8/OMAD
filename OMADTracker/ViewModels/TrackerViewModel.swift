import Foundation
import SwiftData

class TrackerViewModel: ObservableObject {
    let startWeight: Double = 82.0
    let goalWeight:  Double = 79.0
    let programDays: Int   = 28
    /// Fixed daily deficit assuming full activity (gym 400 + walks 150 = 550 kcal exercise)
    let baseDeficit: Int   = 820
    /// Expected exercise kcal per day: dog walks (150) + gym (400)
    let assumedExerciseKcal: Int = 550

    // MARK: - Weight

    func logWeight(_ kg: Double, modelContext: ModelContext) {
        let entry = WeightEntry(date: Date(), weightKg: kg)
        modelContext.insert(entry)
        try? modelContext.save()
    }

    func projectedWeight(entries: [WeightEntry]) -> Double? {
        guard !entries.isEmpty else { return nil }
        let sorted = entries.sorted { $0.date < $1.date }
        guard let first = sorted.first else { return nil }

        let daysSinceStart = Date().timeIntervalSince(first.date) / 86400
        guard daysSinceStart > 0 else { return sorted.last?.weightKg }

        let totalLoss = startWeight - (sorted.last?.weightKg ?? startWeight)
        let ratePerDay = totalLoss / daysSinceStart
        let remainingDays = Double(programDays) - daysSinceStart
        return (sorted.last?.weightKg ?? startWeight) - (ratePerDay * remainingDays)
    }

    func lostWeight(entries: [WeightEntry]) -> Double {
        let current = entries.sorted { $0.date < $1.date }.last?.weightKg ?? startWeight
        return startWeight - current
    }

    func currentWeight(entries: [WeightEntry]) -> Double {
        entries.sorted { $0.date < $1.date }.last?.weightKg ?? startWeight
    }

    // MARK: - Water

    func addWater(_ ml: Int, existingEntry: WaterEntry?, date: Date = Date(), modelContext: ModelContext) {
        if let entry = existingEntry {
            entry.totalMl += ml
        } else {
            let entry = WaterEntry(date: Calendar.current.startOfDay(for: date), totalMl: ml)
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }

    // MARK: - Exercise

    func caloriesPerMinute(for type: String) -> Int {
        switch type {
        case "Walking":  return 5
        case "Gym":      return 7
        case "Cycling":  return 8
        default:         return 5
        }
    }

    /// Log exercise with optional explicit kcal override (for quick-log presets).
    func logExercise(type: String, minutes: Int, kcalOverride: Int? = nil, notes: String, modelContext: ModelContext) {
        let kcal = kcalOverride ?? caloriesPerMinute(for: type) * minutes
        let entry = ExerciseEntry(
            date: Date(),
            type: type,
            durationMinutes: minutes,
            caloriesBurned: kcal,
            notes: notes
        )
        modelContext.insert(entry)
        try? modelContext.save()
    }

    /// Log both dog walks and gym in a single call. Returns total kcal logged.
    @discardableResult
    func logFullDayActivity(modelContext: ModelContext) -> Int {
        logExercise(type: "Walking", minutes: 30, kcalOverride: 150, notes: "Dog walks × 2", modelContext: modelContext)
        logExercise(type: "Gym",     minutes: 60, kcalOverride: 400, notes: "Gym — 1hr mixed", modelContext: modelContext)
        return 550
    }

    func todayExerciseCalories(entries: [ExerciseEntry]) -> Int {
        let today = Date().startOfDay
        return entries
            .filter { $0.date >= today && $0.date < today.endOfDay }
            .reduce(0) { $0 + $1.caloriesBurned }
    }

    /// Deficit adjusted for actual exercise vs assumed 550 kcal.
    /// If you did more than assumed → bigger deficit. Less → smaller deficit (with warning).
    func adjustedDeficit(exerciseCalories: Int) -> Int {
        let delta = exerciseCalories - assumedExerciseKcal
        return baseDeficit + delta
    }

    /// Returns a warning string if exercise is below the assumed 550 kcal target, else nil.
    func exerciseShortfallWarning(exerciseCalories: Int) -> String? {
        guard exerciseCalories < assumedExerciseKcal else { return nil }
        let shortfall = assumedExerciseKcal - exerciseCalories
        let reducedDeficit = max(0, baseDeficit - shortfall)
        return "You're ~\(shortfall) kcal short on exercise today — deficit is ~\(reducedDeficit) kcal"
    }

    func weeklyExerciseSummary(entries: [ExerciseEntry]) -> (minutes: Int, calories: Int, daysActive: Int) {
        let weekStart = Calendar.current.date(
            from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()

        let weekEntries = entries.filter { $0.date >= weekStart }
        let minutes  = weekEntries.reduce(0) { $0 + $1.durationMinutes }
        let calories = weekEntries.reduce(0) { $0 + $1.caloriesBurned }

        var activeDays = Set<String>()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        for entry in weekEntries {
            activeDays.insert(fmt.string(from: entry.date))
        }

        return (minutes: minutes, calories: calories, daysActive: activeDays.count)
    }

    /// Returns 7 bools (Mon–Sun) indicating which days this week had ≥550 kcal exercise logged.
    func weeklyFullActivityDays(entries: [ExerciseEntry]) -> [Bool] {
        let cal = Calendar.current
        let weekStart = cal.date(
            from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()

        var dayKcal = [Int](repeating: 0, count: 7)
        let fmt = DateFormatter()
        fmt.dateFormat = "e" // 1=Sun, 2=Mon ... 7=Sat in gregorian

        for entry in entries where entry.date >= weekStart {
            // Convert weekday to Mon-based index (0=Mon, 6=Sun)
            let weekday = cal.component(.weekday, from: entry.date)
            let index = (weekday + 5) % 7
            dayKcal[index] += entry.caloriesBurned
        }

        return dayKcal.map { $0 >= assumedExerciseKcal }
    }
}
