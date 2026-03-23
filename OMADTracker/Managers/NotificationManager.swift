import UserNotifications
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private init() {}

    enum NotificationKey: String, CaseIterable {
        case mealPrep    = "notif_meal_prep"
        case eatingOpen  = "notif_eating_open"
        case eatingClose = "notif_eating_close"
        case logWeight   = "notif_log_weight"
        case waterCheck  = "notif_water_check"

        var displayName: String {
            switch self {
            case .mealPrep:    return "Meal Prep Reminder (12:30 PM)"
            case .eatingOpen:  return "Eating Window Open (1:00 PM)"
            case .eatingClose: return "Eating Window Closing (2:00 PM)"
            case .logWeight:   return "Log Weight Reminder (8:00 PM)"
            case .waterCheck:  return "Water Goal Check (9:00 PM)"
            }
        }
    }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for key in NotificationKey.allCases {
            if isEnabled(key) {
                schedule(key)
            }
        }
    }

    private func schedule(_ key: NotificationKey) {
        let content = UNMutableNotificationContent()
        content.sound = .default

        let ud = UserDefaults.standard
        let openHour    = ud.object(forKey: "mealWindowOpenHour")    != nil ? ud.integer(forKey: "mealWindowOpenHour")    : 13
        let openMinute  = ud.object(forKey: "mealWindowOpenMinute")  != nil ? ud.integer(forKey: "mealWindowOpenMinute")  : 0
        let closeHour   = ud.object(forKey: "mealWindowCloseHour")   != nil ? ud.integer(forKey: "mealWindowCloseHour")   : 14
        let closeMinute = ud.object(forKey: "mealWindowCloseMinute") != nil ? ud.integer(forKey: "mealWindowCloseMinute") : 0
        let waterTarget = ud.object(forKey: "dailyWaterTargetMl")    != nil ? ud.integer(forKey: "dailyWaterTargetMl")    : 2500

        var hour = 12
        var minute = 0

        switch key {
        case .mealPrep:
            content.title = "Time to prep your OMAD meal 🍱"
            content.body  = "Today is \(Date().displayDayName) — get ready!"
            // 30 min before window opens
            let prepTotal = openHour * 60 + openMinute - 30
            hour = max(0, prepTotal / 60); minute = ((prepTotal % 60) + 60) % 60
        case .eatingOpen:
            content.title = "Eating window open 🥗"
            content.body  = "Enjoy your OMAD meal!"
            hour = openHour; minute = openMinute
        case .eatingClose:
            content.title = "Eating window closing soon ⏰"
            let fmt = DateFormatter()
            fmt.dateFormat = "h:mm a"
            var comps = DateComponents(); comps.hour = closeHour; comps.minute = closeMinute
            let closeStr = (Calendar.current.date(from: comps).map { fmt.string(from: $0) }) ?? "\(closeHour):00"
            content.body  = "Wrap up your meal — window closes at \(closeStr)."
            hour = closeHour; minute = closeMinute
        case .logWeight:
            content.title = "Log your weight for today 📊"
            content.body  = "Keep your streak going!"
            hour = 20; minute = 0
        case .waterCheck:
            content.title = "Have you hit your water goal? 💧"
            content.body  = "\(waterTarget) ml target — tap to check progress."
            hour = 21; minute = 0
        }

        var components = DateComponents()
        components.hour   = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: key.rawValue,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func toggle(_ key: NotificationKey, enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: key.rawValue)
        if enabled {
            schedule(key)
        } else {
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [key.rawValue])
        }
    }

    func isEnabled(_ key: NotificationKey) -> Bool {
        guard UserDefaults.standard.object(forKey: key.rawValue) != nil else { return true }
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
}
