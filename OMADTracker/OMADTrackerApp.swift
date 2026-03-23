import SwiftUI
import SwiftData

@main
struct OMADTrackerApp: App {
    @StateObject private var fastingManager = FastingManager()
    @StateObject private var healthManager  = HealthManager()
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "onboardingComplete")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fastingManager)
                .environmentObject(healthManager)
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView { requestPermissions in
                        UserDefaults.standard.set(true, forKey: "onboardingComplete")
                        showOnboarding = false
                        guard requestPermissions else { return }
                        // Wait for sheet to dismiss, then request permissions sequentially
                        Task {
                            try? await Task.sleep(nanoseconds: 700_000_000)
                            // HealthKit first — must complete before notifications dialog
                            await healthManager.requestHealthKitPermission()
                            // Then notifications
                            await withCheckedContinuation { continuation in
                                NotificationManager.shared.requestPermission { granted in
                                    if granted { NotificationManager.shared.scheduleAll() }
                                    continuation.resume()
                                }
                            }
                        }
                    }
                }
        }
        .modelContainer(for: [
            WeightEntry.self,
            WaterEntry.self,
            ExerciseEntry.self,
            FastEntry.self,
            CustomFood.self,
            FoodLog.self
        ])
    }
}
