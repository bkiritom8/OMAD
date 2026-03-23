import Foundation
import SwiftData

#if canImport(HealthKit)
import HealthKit
#endif

@MainActor
class HealthManager: ObservableObject {
    @Published var isAuthorized = false

    #if canImport(HealthKit)
    private let healthStore = HKHealthStore()
    #endif

    func requestHealthKitPermission() async -> Bool {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return false }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.stepCount)
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            return false
        }
        #else
        return false
        #endif
    }

    func fetchTodaysWorkouts() async -> [ExerciseEntry] {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return [] }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let predicate = HKQuery.predicateForSamples(withStart: today, end: tomorrow)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let entries = (samples as? [HKWorkout] ?? []).map { workout -> ExerciseEntry in
                    let type = Self.mapWorkoutType(workout.workoutActivityType)
                    let kcal = Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0)
                    let minutes = Int(workout.duration / 60)
                    return ExerciseEntry(
                        date: workout.startDate,
                        type: type,
                        durationMinutes: max(1, minutes),
                        caloriesBurned: kcal,
                        notes: "Imported from Apple Health"
                    )
                }
                continuation.resume(returning: entries)
            }
            self.healthStore.execute(query)
        }
        #else
        return []
        #endif
    }

    func fetchTodaysActiveCalories() async -> Int {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return 0 }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        return await withCheckedContinuation { continuation in
            let type = HKQuantityType(.activeEnergyBurned)
            let predicate = HKQuery.predicateForSamples(withStart: today, end: tomorrow)
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let kcal = Int(stats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
                continuation.resume(returning: kcal)
            }
            self.healthStore.execute(query)
        }
        #else
        return 0
        #endif
    }

    func fetchTodaysSteps() async -> Int {
        #if canImport(HealthKit)
        guard HKHealthStore.isHealthDataAvailable() else { return 0 }
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        return await withCheckedContinuation { continuation in
            let type = HKQuantityType(.stepCount)
            let predicate = HKQuery.predicateForSamples(withStart: today, end: tomorrow)
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let steps = Int(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                continuation.resume(returning: steps)
            }
            self.healthStore.execute(query)
        }
        #else
        return 0
        #endif
    }

    #if canImport(HealthKit)
    private nonisolated static func mapWorkoutType(_ type: HKWorkoutActivityType) -> String {
        switch type {
        case .running, .walking:
            return "Walking"
        case .traditionalStrengthTraining, .functionalStrengthTraining, .crossTraining:
            return "Gym"
        case .cycling:
            return "Cycling"
        default:
            return "Walking"
        }
    }
    #endif
}
