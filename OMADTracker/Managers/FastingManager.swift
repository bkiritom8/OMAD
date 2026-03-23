import Foundation
import SwiftUI
import SwiftData

class FastingManager: ObservableObject {
    @Published var isFasting: Bool = false
    @Published var elapsedHours: Double = 0

    private var startTime: Date?
    private var timer: Timer?

    private let startKey     = "fastingStartTime"
    private let isFastingKey = "isFasting"

    init() {
        isFasting = UserDefaults.standard.bool(forKey: isFastingKey)
        if let stored = UserDefaults.standard.object(forKey: startKey) as? Date {
            startTime = stored
        }
        updateElapsed()
        if isFasting {
            startTimer()
        }
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Computed

    var elapsedString: String {
        let totalMinutes = Int(elapsedHours * 60)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        return String(format: "%02d:%02d", h, m)
    }

    var progressFraction: Double {
        min(elapsedHours / 21.0, 1.0)
    }

    var fastingColor: Color {
        Color.fastingColor(hours: elapsedHours)
    }

    var eatingWindowMessage: String {
        let now = Date()
        let cal = Calendar.current
        var open = cal.dateComponents([.year, .month, .day], from: now)
        open.hour = 13; open.minute = 0; open.second = 0
        var closeComps = cal.dateComponents([.year, .month, .day], from: now)
        closeComps.hour = 14; closeComps.minute = 0; closeComps.second = 0

        guard let openTime  = cal.date(from: open),
              let closeTime = cal.date(from: closeComps) else {
            return "Eating window: 1–2 PM"
        }

        if now < openTime {
            let diff = Int(openTime.timeIntervalSince(now))
            let h = diff / 3600
            let m = (diff % 3600) / 60
            return "Eating window opens in \(h)h \(m)m"
        } else if now < closeTime {
            let diff = Int(closeTime.timeIntervalSince(now))
            let h = diff / 3600
            let m = (diff % 3600) / 60
            return "Eating window closes in \(h)h \(m)m"
        } else {
            return "Eating window closed for today"
        }
    }

    /// Motivational tip shown when in the optimal fat-burning window (18–21h).
    var fastingTip: String? {
        guard elapsedHours >= 18 && elapsedHours < 21 else { return nil }
        return "You're in the optimal fat-burning window. Open your eating window at 1 PM."
    }

    // MARK: - Actions

    func startFast() {
        let now = Date()
        startTime = now
        isFasting = true
        UserDefaults.standard.set(now,  forKey: startKey)
        UserDefaults.standard.set(true, forKey: isFastingKey)
        updateElapsed()
        startTimer()
    }

    func breakFast(modelContext: ModelContext) {
        let now = Date()
        let duration: Double
        if let start = startTime {
            duration = now.timeIntervalSince(start) / 3600
            let entry = FastEntry(startTime: start, endTime: now, durationHours: duration)
            modelContext.insert(entry)
            try? modelContext.save()
        }
        isFasting  = false
        elapsedHours = 0
        startTime  = nil
        UserDefaults.standard.set(false, forKey: isFastingKey)
        UserDefaults.standard.removeObject(forKey: startKey)
        stopTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateElapsed()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateElapsed() {
        guard let start = startTime else {
            elapsedHours = 0
            return
        }
        elapsedHours = Date().timeIntervalSince(start) / 3600
    }
}
