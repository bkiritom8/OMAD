import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// 0 = Monday, 6 = Sunday
    var weekdayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: self)
        return (weekday + 5) % 7
    }

    var displayDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    var displayTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    func hoursElapsed(since start: Date) -> Double {
        return self.timeIntervalSince(start) / 3600
    }

    func hhmmElapsed(since start: Date) -> String {
        let total = max(0, Int(self.timeIntervalSince(start)))
        let h = total / 3600
        let m = (total % 3600) / 60
        return String(format: "%02d:%02d", h, m)
    }

    static func dateOnly(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    var isToday: Bool {
        let today = Date().startOfDay
        return self >= today && self < today.endOfDay
    }
}
