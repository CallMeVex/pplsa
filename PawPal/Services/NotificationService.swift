import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleStreakReminderIfNeeded(loggedInToday: Bool) async {
        guard !loggedInToday else { return }
        let content = UNMutableNotificationContent()
        content.title = "Keep your streak alive"
        content.body = "Open PawPal before midnight to protect your streak."
        content.sound = .default

        var date = DateComponents()
        date.hour = AppConstants.streakReminderHour
        date.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: "streak-reminder", content: content, trigger: trigger)
        try? UNUserNotificationCenter.current().add(request)
    }
}
