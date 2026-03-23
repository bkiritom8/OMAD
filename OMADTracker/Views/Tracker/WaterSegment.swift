import SwiftUI
import SwiftData

private let flOzToMl: Double = 29.5735

struct WaterSegment: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WaterEntry.date) private var waterEntries: [WaterEntry]

    @StateObject private var vm = TrackerViewModel()
    @State private var customAmount = ""
    @AppStorage("waterUnitPreference") private var waterUnitPref: String = "ml"

    private var useFlOz: Bool { waterUnitPref == "floz" }

    private let targetMl = 2500
    private let flOzQuickAmounts = [8, 16, 24, 32]   // fl oz
    private let mlQuickAmounts   = [250, 500, 750, 1000]

    private var todayEntry: WaterEntry? {
        let today = Date().startOfDay
        return waterEntries.first(where: { $0.date >= today && $0.date < today.endOfDay })
    }
    private var todayMl: Int { todayEntry?.totalMl ?? 0 }
    private var progress: Double { min(Double(todayMl) / Double(targetMl), 1.0) }

    private var displayAmount: String {
        useFlOz ? String(format: "%.0f", Double(todayMl) / flOzToMl) : "\(todayMl)"
    }
    private var displayTarget: String {
        useFlOz ? "/ 85 fl oz" : "/ \(targetMl) ml"
    }

    private var customMlPreview: String? {
        guard useFlOz, let value = Double(customAmount), value > 0 else { return nil }
        let ml = Int((value * flOzToMl).rounded())
        return "= \(ml) ml"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Unit toggle
                Picker("Unit", selection: $waterUnitPref) {
                    Text("ml").tag("ml")
                    Text("fl oz").tag("floz")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Circular ring
                CircularProgressRing(
                    progress: progress,
                    color: .blue,
                    lineWidth: 20,
                    size: 200
                ) {
                    VStack(spacing: 4) {
                        Text(displayAmount)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.blue)
                        Text(displayTarget)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if todayMl >= targetMl {
                            Text("Goal reached!")
                                .font(.caption2)
                                .foregroundStyle(Color.primaryGreen)
                        }
                    }
                }

                // Quick add buttons
                HStack(spacing: 8) {
                    if useFlOz {
                        ForEach(flOzQuickAmounts, id: \.self) { oz in
                            Button {
                                vm.addWater(Int((Double(oz) * flOzToMl).rounded()),
                                            existingEntry: todayEntry, modelContext: modelContext)
                            } label: {
                                VStack(spacing: 2) {
                                    Text("+\(oz) fl oz")
                                        .font(.caption.weight(.medium))
                                    Text("(\(Int((Double(oz) * flOzToMl).rounded()))ml)")
                                        .font(.caption2)
                                        .foregroundStyle(.blue.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    } else {
                        ForEach(mlQuickAmounts, id: \.self) { ml in
                            Button {
                                vm.addWater(ml, existingEntry: todayEntry, modelContext: modelContext)
                            } label: {
                                Text(ml >= 1000 ? "+1L" : "+\(ml)ml")
                                    .font(.subheadline.weight(.medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.blue.opacity(0.12))
                                    .foregroundStyle(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Custom amount
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        TextField(useFlOz ? "Enter fl oz" : "Custom ml", text: $customAmount)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            if let value = Double(customAmount), value > 0 {
                                let ml = useFlOz ? Int((value * flOzToMl).rounded()) : Int(value)
                                vm.addWater(ml, existingEntry: todayEntry, modelContext: modelContext)
                                customAmount = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .disabled(customAmount.isEmpty)
                    }
                    if let preview = customMlPreview {
                        Text(preview)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // 7-day chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("7-Day History")
                        .font(.headline)
                        .padding(.horizontal)
                    WaterChart(entries: waterEntries, useFlOz: useFlOz)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}
