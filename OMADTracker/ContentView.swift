import SwiftUI

struct ContentView: View {
    @EnvironmentObject var fastingManager: FastingManager

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }

            MealPlanView()
                .tabItem {
                    Label("Meal Plan", systemImage: "calendar")
                }

            FoodCheckerView()
                .tabItem {
                    Label("Checker", systemImage: "magnifyingglass")
                }

            TrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "chart.bar.fill")
                }

            GroceryView()
                .tabItem {
                    Label("Groceries", systemImage: "cart.fill")
                }
        }
        .tint(Color.primaryGreen)
    }
}

#Preview {
    ContentView()
        .environmentObject(FastingManager())
        .modelContainer(for: [
            WeightEntry.self,
            WaterEntry.self,
            ExerciseEntry.self,
            FastEntry.self,
            CustomFood.self,
            FoodLog.self
        ], inMemory: true)
}
