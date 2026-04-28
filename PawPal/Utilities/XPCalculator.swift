import Foundation

enum XPCalculator {
    static func requiredXP(for level: Int) -> Double {
        100.0 * pow(Double(level), 1.5)
    }

    static func totalMultiplier(
        rarity: PetRarity,
        favoritismActive: Bool,
        premiumActive: Bool,
        mood: PetMood,
        isSick: Bool
    ) -> Double {
        var value = rarity.multiplier
        if favoritismActive { value *= 1.5 }
        if premiumActive { value *= 1.2 }
        if mood == .sad || mood == .neglected { value *= 0.5 }
        if mood == .sick || isSick { value *= 0.0 }
        return value
    }

    static func levelTitle(for level: Int) -> String {
        switch level {
        case 1...9: return "Novice Trainer"
        case 10...24: return "Pet Caretaker"
        case 25...49: return "Pet Enthusiast"
        case 50...74: return "Pet Master"
        case 75...99: return "Pet Veteran"
        case 100...149: return "Pet Legend"
        default: return "Pet Mythic"
        }
    }
}
