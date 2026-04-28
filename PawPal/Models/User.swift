import Foundation

struct AppUser: Codable, Identifiable, Equatable {
    let id: UUID
    var email: String
    var username: String
    var bio: String?
    var avatarURL: String?
    var level: Int
    var xp: Double
    var pawsBalance: Int
    var streakCount: Int
    var streakSavers: Int
    var premiumActive: Bool
    var onboardingCompleted: Bool
    var createdAt: Date
}

struct PublicProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var username: String
    var level: Int
    var levelTitle: String
    var premiumActive: Bool
}
