import Foundation

enum PetLogic {
    static func mood(for pet: Pet) -> PetMood {
        if pet.isSick { return .sick }
        if Date().timeIntervalSince(pet.lastCaredAt) >= 86_400 { return .neglected }
        if pet.happiness > 70 { return .happy }
        if pet.happiness < 30 { return .sad }
        return .neutral
    }

    static func applyDecay(to pet: inout Pet, now: Date = .init()) {
        let elapsed = now.timeIntervalSince(pet.lastCaredAt)
        let hungerSteps = Int(elapsed / (4 * 3600))
        let cleanSteps = Int(elapsed / (6 * 3600))
        pet.hunger = min(100, pet.hunger + (hungerSteps * 5))
        pet.cleanliness = max(0, pet.cleanliness - (cleanSteps * 5))
        pet.mood = mood(for: pet)
    }

    static func canPlay(_ pet: Pet) -> Bool { pet.energy >= 20 && pet.sleepingUntil == nil }
    static func canSleep(_ pet: Pet) -> Bool { pet.energy < 50 && pet.sleepingUntil == nil }

    static func travelScore(
        for parentId: UUID,
        pet: Pet,
        careCountForParent: Int,
        hoursSinceVisitedParent: Int
    ) -> Double {
        let base = Double(careCountForParent) * 1.8 + Double(hoursSinceVisitedParent) * 0.9
        let moodBoost = pet.mood == .happy ? 10.0 : 3.0
        switch pet.personality {
        case .mamasChild:
            return parentId == pet.ownerAId ? base + 25 + moodBoost : base + moodBoost
        case .troublemaker:
            return base + Double(Int.random(in: 0...15)) + moodBoost
        case .clingy:
            return base * 0.5 + moodBoost
        case .independent:
            return base * 1.3 + 8
        case .foodie:
            return base + (pet.favoriteFood.isEmpty ? 0 : 12) + moodBoost
        }
    }

    static func isOverfeeding(_ pet: Pet) -> Bool { pet.hunger < 20 }
}
