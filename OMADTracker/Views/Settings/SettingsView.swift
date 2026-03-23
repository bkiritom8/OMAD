import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("Notifications") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notification Schedule", systemImage: "bell.fill")
                    }
                }

                Section("Your Goal") {
                    LabeledContent("Starting Weight", value: "82.0 kg")
                    LabeledContent("Goal Weight", value: "79.0 kg")
                    LabeledContent("Program Length", value: "4 weeks")
                    LabeledContent("Weekly Loss Target", value: "0.75 kg/week")
                    LabeledContent("Daily Calories", value: "1,680 kcal")
                    LabeledContent("Daily Protein", value: "153g")
                    LabeledContent("Daily Fiber", value: "41g")
                    LabeledContent("Water Goal", value: "2,500 ml")
                }

                Section("Daily Burn") {
                    LabeledContent("Base TDEE", value: "1,950 kcal")
                    LabeledContent("Dog Walks 2 × 15 min", value: "+150 kcal")
                    LabeledContent("Gym 1hr Mixed", value: "+400 kcal")
                    LabeledContent("Total Burn", value: "~2,500 kcal")
                    LabeledContent("Daily Deficit", value: "~820 kcal")
                }

                Section("Meal Window") {
                    LabeledContent("Eating Window", value: "1:00 PM – 2:00 PM")
                    LabeledContent("Fasting Target", value: "21 hours")
                }

                Section("Integrations") {
                    Toggle(isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "autoSyncHealth") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "autoSyncHealth") }
                    )) {
                        Label("Auto-sync Apple Health on open", systemImage: "heart.fill")
                    }
                    .tint(.green)
                    Toggle(isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "showHealthBadges") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "showHealthBadges") }
                    )) {
                        Label("Show Health import badges", systemImage: "h.circle.fill")
                    }
                    .tint(.green)
                }

                Section("App") {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Diet Type", value: "OMAD (One Meal A Day)")
                }

                Section {
                    Button(role: .destructive) {
                        showClearConfirm = true
                    } label: {
                        Label("Clear Today's Log", systemImage: "trash")
                    }
                } footer: {
                    Text("Deletes all food logged today and resets meal plan checkmarks.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Clear Today's Log?",
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Clear", role: .destructive) { clearToday() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all food entries logged today and uncheck all meal plan items.")
            }
        }
    }

    private func clearToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<FoodLog>(
            predicate: #Predicate { log in
                log.date >= today && log.date < tomorrow
            }
        )
        if let logs = try? modelContext.fetch(descriptor) {
            for log in logs { modelContext.delete(log) }
        }
        try? modelContext.save()
        // Clear today's checked meal items from UserDefaults
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = "checkedItems_\(formatter.string(from: Date()))"
        UserDefaults.standard.removeObject(forKey: key)
    }
}

#Preview {
    SettingsView()
}
