import Foundation
import SwiftUI

enum AppConstants {
    static let supabaseURL = URL(string: "https://zehzreygfwrgfzbndsmj.supabase.co")!
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InplaHpyZXlnZndyZ2Z6Ym5kc21qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczOTU5NDUsImV4cCI6MjA5Mjk3MTk0NX0.UOash20GdPc5PXufzlYNgqRa2ek5eMBTvgbZ0lvcJzE"
    static let revenueCatAPIKey = "YOUR_REVENUECAT_PUBLIC_API_KEY"
    static let pageSize = 20
    static let streakReminderHour = 20
}

enum Theme {
    static let primary = Color(red: 124 / 255, green: 58 / 255, blue: 237 / 255)
    static let dark = Color(red: 76 / 255, green: 29 / 255, blue: 149 / 255)
    static let lightBackground = Color(red: 237 / 255, green: 233 / 255, blue: 254 / 255)
    static let cornerRadius: CGFloat = 12
}

enum AppNotificationName {
    static let petDidUpdate = Notification.Name("petDidUpdate")
    static let authDidChange = Notification.Name("authDidChange")
}
