import Foundation

enum PetSpecies: String, Codable, CaseIterable, Identifiable {
    case dog
    case cat
    case parrot
    var id: String { rawValue }
}

enum PetRarity: String, Codable, CaseIterable {
    case common, uncommon, rare, epic, legendary, mythic
    var multiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.2
        case .rare: return 1.5
        case .epic: return 2.0
        case .legendary: return 2.5
        case .mythic: return 3.0
        }
    }
}

enum PetPersonality: String, Codable, CaseIterable {
    case mamasChild = "Mama's Boy/Girl"
    case troublemaker = "Troublemaker"
    case clingy = "Clingy"
    case independent = "Independent"
    case foodie = "Foodie"
}

enum PetMood: String, Codable {
    case happy
    case neutral
    case sad
    case sick
    case neglected
}

struct Pet: Codable, Identifiable, Equatable {
    let id: UUID
    var ownerAId: UUID
    var ownerBId: UUID?
    var currentOwnerId: UUID
    var name: String
    var species: PetSpecies
    var rarity: PetRarity
    var personality: PetPersonality
    var favoriteFood: String
    var happiness: Int
    var hunger: Int
    var cleanliness: Int
    var energy: Int
    var mood: PetMood
    var xp: Double
    var level: Int
    var sleepingUntil: Date?
    var isSick: Bool
    var muddyPawsActive: Bool
    var lastCaredAt: Date
    var hatchedAt: Date
}

enum CareAction: String, Codable {
    case feed
    case bathe
    case play
    case sleep
    case cleanup
    case medicine
}
