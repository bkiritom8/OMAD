import SwiftUI
import SwiftData

struct WeightSegment: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightEntry.date) private var weightEntries: [WeightEntry]

    @StateObject private var vm = TrackerViewModel()
    @State private var showLogWeight = false
    @State private var weightInput   = ""

    /// Stored once on first launch so the projection line has a fixed start date.
    @AppStorage("planStartDate") private var planStartDateInterval: Double = Date().timeIntervalSince1970
    private var planStartDate: Date { Date(timeIntervalSince1970: planStartDateInterval) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Log button
                Button {
                    showLogWeight = true
                } label: {
                    Label("Log Today's Weight", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.primaryGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                // Chart
                if !weightEntries.isEmpty {
                    WeightChart(entries: weightEntries, planStartDate: planStartDate)
                        .padding(.horizontal)
                } else {
                    ContentUnavailableView(
                        "No Weight Data",
                        systemImage: "scalemass",
                        description: Text("Log your first weight entry above.")
                    )
                    .frame(height: 180)
                }

                // Weigh-in reminder
                HStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundStyle(.secondary)
                    Text("Weigh yourself every morning after waking, before eating or drinking. Post-meal weight is not accurate — ignore it.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                // Stats row
                statsRow

                // Last 7 entries
                if !weightEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Entries")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(weightEntries.suffix(7).reversed()) { entry in
                            HStack {
                                Text(entry.date.displayDate)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(String(format: "%.1f kg", entry.weightKg))
                                    .font(.subheadline.weight(.semibold))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Persist plan start date once on first launch
            if !UserDefaults.standard.bool(forKey: "planStartDateSet") {
                planStartDateInterval = Date().timeIntervalSince1970
                UserDefaults.standard.set(true, forKey: "planStartDateSet")
            }
        }
        .sheet(isPresented: $showLogWeight) {
            NavigationStack {
                Form {
                    Section("Weight (kg)") {
                        TextField("e.g. 81.5", text: $weightInput)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Log Weight")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showLogWeight = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let kg = Double(weightInput) {
                                vm.logWeight(kg, modelContext: modelContext)
                            }
                            showLogWeight = false
                            weightInput = ""
                        }
                        .disabled(weightInput.isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(title: "Start", value: "82.0 kg")
            Divider().frame(height: 40)
            statCell(title: "Current",
                     value: String(format: "%.1f kg", vm.currentWeight(entries: weightEntries)))
            Divider().frame(height: 40)
            statCell(title: "Lost",
                     value: String(format: "%.1f kg", vm.lostWeight(entries: weightEntries)))
            Divider().frame(height: 40)
            statCell(title: "Projected",
                     value: vm.projectedWeight(entries: weightEntries).map {
                         String(format: "%.1f kg", $0)
                     } ?? "—")
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func statCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.primaryGreen)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
