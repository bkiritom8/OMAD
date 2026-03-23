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
        let target = UserDefaults.standard.integer(forKey: "fastingTargetHours")
        let hours = target > 0 ? Double(target) : 21.0
        return min(elapsedHours / hours, 1.0)
    }

    var fastingColor: Color {
        Color.fastingColor(hours: elapsedHours)
    }

    var eatingWindowMessage: String {
        let now = Date()
        let cal = Calendar.current
        let ud = UserDefaults.standard
        var open = cal.dateComponents([.year, .month, .day], from: now)
        open.hour   = ud.object(forKey: "mealWindowOpenHour")   != nil ? ud.integer(forKey: "mealWindowOpenHour")   : 13
        open.minute = ud.object(forKey: "mealWindowOpenMinute") != nil ? ud.integer(forKey: "mealWindowOpenMinute") : 0
        open.second = 0
        var closeComps = cal.dateComponents([.year, .month, .day], from: now)
        closeComps.hour   = ud.object(forKey: "mealWindowCloseHour")   != nil ? ud.integer(forKey: "mealWindowCloseHour")   : 14
        closeComps.minute = ud.object(forKey: "mealWindowCloseMinute") != nil ? ud.integer(forKey: "mealWindowCloseMinute") : 0
        closeComps.second = 0

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

    /// Motivational tip shown when in the optimal fat-burning window (18–target h).
    var fastingTip: String? {
        let target = UserDefaults.standard.integer(forKey: "fastingTargetHours")
        let hours = target > 0 ? Double(target) : 21.0
        guard elapsedHours >= 18 && elapsedHours < hours else { return nil }
        let ud = UserDefaults.standard
        let openHour   = ud.object(forKey: "mealWindowOpenHour")   != nil ? ud.integer(forKey: "mealWindowOpenHour")   : 13
        let openMinute = ud.object(forKey: "mealWindowOpenMinute") != nil ? ud.integer(forKey: "mealWindowOpenMinute") : 0
        let timeStr = openMinute == 0 ? "\(openHour % 12 == 0 ? 12 : openHour % 12) \(openHour < 12 ? "AM" : "PM")" : "\(openHour % 12 == 0 ? 12 : openHour % 12):\(String(format: "%02d", openMinute)) \(openHour < 12 ? "AM" : "PM")"
        return "You're in the optimal fat-burning window. Open your eating window at \(timeStr)."
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
