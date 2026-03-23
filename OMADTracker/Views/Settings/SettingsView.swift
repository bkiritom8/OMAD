import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showClearConfirm = false

    // Meal window
    @AppStorage("mealWindowOpenHour")    private var openHour: Int    = 13
    @AppStorage("mealWindowOpenMinute")  private var openMinute: Int  = 0
    @AppStorage("mealWindowCloseHour")   private var closeHour: Int   = 14
    @AppStorage("mealWindowCloseMinute") private var closeMinute: Int = 0
    @AppStorage("fastingTargetHours")    private var fastingHours: Int = 21

    // Daily targets
    @AppStorage("dailyCalorieTarget") private var calorieTarget: Double = 1680
    @AppStorage("dailyProteinTarget") private var proteinTarget: Double = 153
    @AppStorage("dailyFiberTarget")   private var fiberTarget: Double   = 41
    @AppStorage("dailyWaterTargetMl") private var waterTarget: Int      = 2500

    // Weight goals
    @AppStorage("startWeightKg") private var startWeight: Double = 82.0
    @AppStorage("goalWeightKg")  private var goalWeight: Double  = 79.0

    private var mealOpenBinding: Binding<Date> {
        Binding(
            get: { makeTime(hour: openHour, minute: openMinute) },
            set: { d in
                let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                openHour = c.hour ?? 13
                openMinute = c.minute ?? 0
                NotificationManager.shared.scheduleAll()
            }
        )
    }

    private var mealCloseBinding: Binding<Date> {
        Binding(
            get: { makeTime(hour: closeHour, minute: closeMinute) },
            set: { d in
                let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                closeHour = c.hour ?? 14
                closeMinute = c.minute ?? 0
                NotificationManager.shared.scheduleAll()
            }
        )
    }

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

                Section {
                    DatePicker("Window Opens", selection: mealOpenBinding,
                               displayedComponents: .hourAndMinute)
                    DatePicker("Window Closes", selection: mealCloseBinding,
                               displayedComponents: .hourAndMinute)
                    Stepper("Fasting Target: \(fastingHours)h",
                            value: $fastingHours, in: 16...23)
                } header: {
                    Text("Meal Window")
                } footer: {
                    Text("Notifications reschedule automatically when you change these times.")
                        .font(.caption)
                }

                Section("Your Goal") {
                    doubleRow("Starting Weight", value: $startWeight, unit: "kg")
                    doubleRow("Goal Weight",     value: $goalWeight,  unit: "kg")
                    doubleRow("Daily Calories",  value: $calorieTarget, unit: "kcal")
                    doubleRow("Daily Protein",   value: $proteinTarget, unit: "g")
                    doubleRow("Daily Fiber",     value: $fiberTarget,   unit: "g")
                    intRow("Water Goal",         value: $waterTarget,   unit: "ml")
                }

                Section("Daily Burn") {
                    LabeledContent("Base TDEE",             value: "1,950 kcal")
                    LabeledContent("Dog Walks 2 × 15 min",  value: "+150 kcal")
                    LabeledContent("Gym 1hr Mixed",         value: "+400 kcal")
                    LabeledContent("Total Burn",            value: "~2,500 kcal")
                    LabeledContent("Daily Deficit",         value: "~820 kcal")
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
                    LabeledContent("Version",   value: "1.0")
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

    // MARK: - Helpers

    private func makeTime(hour: Int, minute: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour; comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    private func doubleRow(_ label: String, value: Binding<Double>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 72)
            Text(unit)
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }

    private func intRow(_ label: String, value: Binding<Int>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 72)
            Text(unit)
                .foregroundStyle(.secondary)
                .font(.subheadline)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = "checkedItems_\(formatter.string(from: Date()))"
        UserDefaults.standard.removeObject(forKey: key)
    }
}

#Preview {
    SettingsView()
}
