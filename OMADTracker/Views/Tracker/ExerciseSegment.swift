import SwiftUI
import SwiftData

struct ExerciseSegment: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var healthManager: HealthManager
    @Query(sort: \ExerciseEntry.date, order: .reverse) private var exerciseEntries: [ExerciseEntry]
    @Query private var allFoodLogs: [FoodLog]

    @StateObject private var vm = TrackerViewModel()
    @State private var selectedType    = "Walking"
    @State private var durationMinutes = 30
    @State private var notes           = ""
    @State private var quickLogToast: String? = nil
    @State private var syncBanner: String? = nil
    @State private var showWhoopSheet  = false
    @State private var showHealthDeniedAlert = false

    @AppStorage("autoSyncHealth")   private var autoSyncHealth   = true
    @AppStorage("showHealthBadges") private var showHealthBadges = true

    let exerciseTypes = ["Walking", "Gym", "Yoga", "Other"]

    private var previewBurn: Int { vm.caloriesPerMinute(for: selectedType) * durationMinutes }
    private var todayBurn: Int   { vm.todayExerciseCalories(entries: exerciseEntries) }

    private var todayCaloriesLogged: Double {
        let today = Date().startOfDay
        return allFoodLogs
            .filter { $0.date >= today && $0.date < today.endOfDay }
            .reduce(0) { $0 + $1.calories }
    }

    private var caloriesOver: Double { max(0, todayCaloriesLogged - 1680) }
    private var walkingMinutesNeeded: Int { Int(ceil(caloriesOver / 5)) }

    private var thisWeekEntries: [ExerciseEntry] {
        let weekStart = Calendar.current.date(
            from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        ) ?? Date()
        return exerciseEntries.filter { $0.date >= weekStart }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Health sync buttons
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Button {
                            Task { await syncFromHealth() }
                        } label: {
                            Label("Sync from Health", systemImage: "heart.fill")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)

                        Button {
                            showWhoopSheet = true
                        } label: {
                            Label("WHOOP setup", systemImage: "bolt.heart.fill")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }

                    if let banner = syncBanner {
                        Text(banner)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.primaryGreen)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                .animation(.default, value: syncBanner)

                // MARK: Quick-log presets
                VStack(spacing: 10) {
                    Text("Quick Log")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 10) {
                        quickLogButton(
                            label: "Dog Walks × 2",
                            detail: "30 min · 150 kcal",
                            icon: "figure.walk"
                        ) {
                            vm.logExercise(type: "Walking", minutes: 30, kcalOverride: 150,
                                           notes: "Dog walks × 2", modelContext: modelContext)
                            showToast("Logged dog walks (150 kcal)")
                        }

                        quickLogButton(
                            label: "Gym — 1hr",
                            detail: "60 min · 400 kcal",
                            icon: "dumbbell.fill"
                        ) {
                            vm.logExercise(type: "Gym", minutes: 60, kcalOverride: 400,
                                           notes: "Gym — 1hr mixed", modelContext: modelContext)
                            showToast("Logged gym (400 kcal)")
                        }
                    }

                    Button {
                        vm.logFullDayActivity(modelContext: modelContext)
                        showToast("Logged dog walks (150 kcal) + gym (400 kcal) = 550 kcal total")
                    } label: {
                        Label("Log Both (Full Day — 550 kcal)", systemImage: "checkmark.seal.fill")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primaryGreen)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let toast = quickLogToast {
                        Text(toast)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.primaryGreen)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: Manual log form
                VStack(spacing: 12) {
                    Text("Manual Entry")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Picker("Type", selection: $selectedType) {
                        ForEach(exerciseTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 5...180, step: 5)
                        .font(.subheadline)

                    HStack {
                        Text("Est. burn:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("~\(previewBurn) kcal")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.primaryGreen)
                    }

                    TextField("Notes (optional)", text: $notes)
                        .textFieldStyle(.roundedBorder)
                        .font(.subheadline)

                    Button {
                        vm.logExercise(type: selectedType, minutes: durationMinutes,
                                       notes: notes, modelContext: modelContext)
                        notes = ""
                    } label: {
                        Label("Log Exercise", systemImage: "flame.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primaryGreen)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: Today summary
                VStack(spacing: 8) {
                    HStack {
                        Label("Today's Burn", systemImage: "flame.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.orange)
                        Spacer()
                        Text("\(todayBurn) kcal")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.orange)
                    }
                    HStack {
                        Text("Today's deficit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(vm.adjustedDeficit(exerciseCalories: todayBurn)) kcal")
                            .font(.caption.weight(.semibold))
                    }
                    if let warning = vm.exerciseShortfallWarning(exerciseCalories: todayBurn) {
                        Divider()
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(warning)
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Spacer()
                        }
                    }
                    if caloriesOver > 0 {
                        Divider()
                        HStack(spacing: 6) {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(.red)
                            Text("You're \(Int(caloriesOver)) kcal over from food — walk \(walkingMinutesNeeded) min to compensate")
                                .font(.caption)
                                .foregroundStyle(.red)
                            Spacer()
                        }
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: Weekly summary
                let summary = vm.weeklyExerciseSummary(entries: exerciseEntries)
                let fullDays = vm.weeklyFullActivityDays(entries: exerciseEntries)
                VStack(spacing: 12) {
                    HStack(spacing: 0) {
                        summaryCell(value: "\(summary.minutes)m", label: "Total Min")
                        Divider().frame(height: 36)
                        summaryCell(value: "\(summary.calories)", label: "kcal Burned")
                        Divider().frame(height: 36)
                        summaryCell(value: "\(vm.adjustedDeficit(exerciseCalories: summary.calories / max(summary.daysActive, 1)))",
                                    label: "Avg Deficit")
                    }

                    // 7-dot streak row (Mon–Sun)
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            ForEach(Array(zip(["M","T","W","T","F","S","S"].indices,
                                             ["M","T","W","T","F","S","S"])), id: \.0) { idx, label in
                                VStack(spacing: 3) {
                                    Circle()
                                        .fill(fullDays[idx] ? Color.primaryGreen : Color.secondary.opacity(0.2))
                                        .frame(width: 28, height: 28)
                                        .overlay {
                                            if fullDays[idx] {
                                                Image(systemName: "checkmark")
                                                    .font(.caption2.weight(.bold))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                    Text(label)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        Text("Full activity days (550+ kcal) this week")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // MARK: This week's entries list
                if !thisWeekEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This Week")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(thisWeekEntries) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(entry.type)
                                            .font(.subheadline.weight(.medium))
                                        Text("·")
                                            .foregroundStyle(.secondary)
                                        Text("\(entry.durationMinutes) min")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        if showHealthBadges && entry.notes == "Imported from Apple Health" {
                                            Image(systemName: "heart.fill")
                                                .font(.caption2)
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    if !entry.notes.isEmpty && entry.notes != "Imported from Apple Health" {
                                        Text(entry.notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(entry.caloriesBurned) kcal")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.orange)
                                    Text(entry.date.displayDate)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        }
                        .onDelete { indexSet in
                            for i in indexSet {
                                modelContext.delete(thisWeekEntries[i])
                            }
                            try? modelContext.save()
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .animation(.default, value: quickLogToast)
        .onAppear {
            guard autoSyncHealth else { return }
            Task { await autoSyncFromHealth() }
        }
        .sheet(isPresented: $showWhoopSheet) {
            WhoopInstructionSheet()
        }
        .alert("Health Access Denied", isPresented: $showHealthDeniedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Go to Settings → Privacy & Security → Health → OMAD Tracker to enable access.")
        }
    }

    // MARK: - Sync logic

    private func syncFromHealth() async {
        let granted = await healthManager.requestHealthKitPermission()
        guard granted else {
            showHealthDeniedAlert = true
            return
        }
        let newCount = await insertNewWorkouts(from: await healthManager.fetchTodaysWorkouts())
        if newCount > 0 {
            showSyncBanner("Synced \(newCount) workout\(newCount == 1 ? "" : "s") from Apple Health")
        } else {
            showSyncBanner("Already up to date")
        }
    }

    private func autoSyncFromHealth() async {
        let workouts = await healthManager.fetchTodaysWorkouts()
        let newCount = await insertNewWorkouts(from: workouts)
        if newCount > 0 {
            showSyncBanner("Synced \(newCount) workout\(newCount == 1 ? "" : "s") from Apple Health")
        }
    }

    @discardableResult
    private func insertNewWorkouts(from workouts: [ExerciseEntry]) async -> Int {
        let today = Date().startOfDay
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let existing = exerciseEntries.filter { $0.date >= today && $0.date < tomorrow }
        var newCount = 0
        for workout in workouts {
            let isDuplicate = existing.contains { entry in
                entry.type == workout.type &&
                abs(entry.durationMinutes - workout.durationMinutes) <= 1 &&
                abs(entry.date.timeIntervalSince(workout.date)) < 300
            }
            if !isDuplicate {
                modelContext.insert(workout)
                newCount += 1
            }
        }
        if newCount > 0 {
            try? modelContext.save()
        }
        return newCount
    }

    private func showSyncBanner(_ message: String) {
        syncBanner = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            syncBanner = nil
        }
    }

    // MARK: - Subviews

    private func quickLogButton(label: String, detail: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color.primaryGreen)
                Text(label)
                    .font(.caption.weight(.semibold))
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.primaryGreen.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func showToast(_ message: String) {
        quickLogToast = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            quickLogToast = nil
        }
    }

    private func summaryCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.primaryGreen)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - WHOOP Instruction Sheet

private struct WhoopInstructionSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("To sync WHOOP workouts automatically:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array([
                        "Open the WHOOP app",
                        "Go to Settings → Connected Apps",
                        "Enable Apple Health",
                        "Make sure Workouts and Active Calories are toggled on"
                    ].enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(idx + 1).")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.primaryGreen)
                            Text(step)
                                .font(.subheadline)
                        }
                    }
                }

                Text("Once connected, your WHOOP strain data will appear here automatically when you tap Sync.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        if let url = URL(string: "whoop://") {
                            UIApplication.shared.open(url) { success in
                                if !success, let appStore = URL(string: "https://apps.apple.com/app/whoop/id933944389") {
                                    UIApplication.shared.open(appStore)
                                }
                            }
                        }
                    } label: {
                        Label("Open WHOOP App", systemImage: "arrow.up.forward.app")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.primaryGreen)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button("Got it") { dismiss() }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .navigationTitle("Connect WHOOP to Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
