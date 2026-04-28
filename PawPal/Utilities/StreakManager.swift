import Foundation

struct StreakResult {
    let newCount: Int
    let usedSaver: Bool
    let awardedSaver: Bool
}

enum StreakManager {
    static func updateStreak(
        currentCount: Int,
        streakSavers: Int,
        lastLoginAt: Date?,
        now: Date = .init(),
        calendar: Calendar = .current
    ) -> StreakResult {
        guard let lastLoginAt else {
            return StreakResult(newCount: 1, usedSaver: false, awardedSaver: false)
        }

        let startOfToday = calendar.startOfDay(for: now)
        let startOfLast = calendar.startOfDay(for: lastLoginAt)
        let days = calendar.dateComponents([.day], from: startOfLast, to: startOfToday).day ?? 0

        if days <= 0 { return StreakResult(newCount: currentCount, usedSaver: false, awardedSaver: false) }
        if days == 1 { return streakAdvance(currentCount + 1) }

        let grace = 2 * 3600.0
        if now.timeIntervalSince(startOfToday) <= grace && days == 2 {
            return streakAdvance(currentCount + 1)
        }
        if streakSavers > 0 {
            return StreakResult(newCount: currentCount + 1, usedSaver: true, awardedSaver: false)
        }
        return StreakResult(newCount: 1, usedSaver: false, awardedSaver: false)
    }

    private static func streakAdvance(_ count: Int) -> StreakResult {
        let awarded = count % 7 == 0
        return StreakResult(newCount: count, usedSaver: false, awardedSaver: awarded)
    }

    static func dailyPaws(streak: Int) -> Int {
        let multiplier = min(5, max(1, streak))
        return 10 * multiplier
    }
}
