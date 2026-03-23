import SwiftUI

struct TrackerView: View {
    @EnvironmentObject var fastingManager: FastingManager
    @State private var selectedSegment = 0

    private let segments = ["Weight", "Water", "Exercise", "Fasting"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented control
                Picker("Segment", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { i in
                        Text(segments[i]).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))

                // Content
                switch selectedSegment {
                case 0:
                    WeightSegment()
                case 1:
                    WaterSegment()
                case 2:
                    ExerciseSegment()
                case 3:
                    FastingSegment()
                        .environmentObject(fastingManager)
                default:
                    WeightSegment()
                }
            }
            .navigationTitle("Tracker")
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    TrackerView()
        .environmentObject(FastingManager())
        .modelContainer(for: [WeightEntry.self, WaterEntry.self, ExerciseEntry.self, FastEntry.self], inMemory: true)
}
