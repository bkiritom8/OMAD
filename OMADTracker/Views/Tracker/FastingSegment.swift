import SwiftUI
import SwiftData

struct FastingSegment: View {
    @EnvironmentObject var fastingManager: FastingManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastEntry.startTime, order: .reverse) private var fastHistory: [FastEntry]

    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Large circular timer
                CircularProgressRing(
                    progress: fastingManager.progressFraction,
                    color: fastingManager.fastingColor,
                    lineWidth: 22,
                    size: 240
                ) {
                    VStack(spacing: 6) {
                        Text(fastingManager.elapsedString)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(fastingManager.fastingColor)
                            .scaleEffect(pulse ? 1.04 : 1.0)
                            .animation(
                                fastingManager.elapsedHours >= 21 && fastingManager.elapsedHours < 23
                                    ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                                    : .default,
                                value: pulse
                            )
                        Text("/ 21:00 target")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if fastingManager.elapsedHours >= 21 {
                            Text("Goal reached!")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.teal)
                        }
                    }
                }
                .padding(.top, 8)
                .onAppear { pulse = fastingManager.elapsedHours >= 21 }
                .onChange(of: fastingManager.elapsedHours) { _, hours in
                    pulse = hours >= 21 && hours < 23
                }

                // Eating window message
                Text(fastingManager.eatingWindowMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Tip in green zone (18–21h)
                if let tip = fastingManager.fastingTip {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color.primaryGreen)
                        Text(tip)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.primaryGreen)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.primaryGreen.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }

                // Start / Break button
                Button {
                    if fastingManager.isFasting {
                        fastingManager.breakFast(modelContext: modelContext)
                    } else {
                        fastingManager.startFast()
                    }
                } label: {
                    Text(fastingManager.isFasting ? "Break Fast" : "Start Fast")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(fastingManager.isFasting ? Color.red : Color.primaryGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)

                // Fast history
                if !fastHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fast History")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(fastHistory.prefix(7)) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.startTime.displayDate)
                                        .font(.subheadline.weight(.medium))
                                    Text("Started \(entry.startTime.displayTime)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(format: "%.1fh", entry.durationHours))
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color.fastingColor(hours: entry.durationHours))
                                    Text(entry.endTime != nil ? "Complete" : "Ongoing")
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
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
    }
}
