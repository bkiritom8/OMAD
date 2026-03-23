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
                    OnboardingView {
                        NotificationManager.shared.requestPermission { granted in
                            if granted {
                                NotificationManager.shared.scheduleAll()
                            }
                        }
                        UserDefaults.standard.set(true, forKey: "onboardingComplete")
                        showOnboarding = false
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
