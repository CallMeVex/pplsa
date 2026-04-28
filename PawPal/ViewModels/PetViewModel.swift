import Combine
import Foundation

@MainActor
final class PetViewModel: ObservableObject {
    @Published var pet: Pet?
    @Published var activity: [ActivityMessage] = []
    @Published var isLoading = false
    @Published var toast: String?

    private let service = PetService()

    func loadPet(for userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        do {
            pet = try await service.fetchCurrentPet(for: userId)
            if let petId = pet?.id { activity = try await service.fetchActivity(petId: petId, page: 0) }
        } catch {
            toast = error.localizedDescription
        }
    }

    func hatchStarterPet(ownerId: UUID, name: String, species: PetSpecies) async {
        let favoritePool = ["Berry Kibble", "Fish Cubes", "Seed Mix", "Honey Bites"]
        let newPet = Pet(
            id: UUID(),
            ownerAId: ownerId,
            ownerBId: nil,
            currentOwnerId: ownerId,
            name: name,
            species: species,
            rarity: .common,
            personality: PetPersonality.allCases.randomElement() ?? .independent,
            favoriteFood: favoritePool.randomElement() ?? "Berry Kibble",
            happiness: 70,
            hunger: 35,
            cleanliness: 90,
            energy: 80,
            mood: .happy,
            xp: 0,
            level: 1,
            sleepingUntil: nil,
            isSick: false,
            muddyPawsActive: false,
            lastCaredAt: .init(),
            hatchedAt: .init()
        )
        do {
            try await service.savePet(newPet)
            pet = newPet
        } catch {
            toast = error.localizedDescription
        }
    }

    func perform(action: CareAction, premiumActive: Bool) async {
        guard var current = pet else { return }
        PetLogic.applyDecay(to: &current)
        let favoriteTriggered = action == .feed && Bool.random() && !current.favoriteFood.isEmpty

        switch action {
        case .feed:
            if PetLogic.isOverfeeding(current) {
                current.isSick = true
                current.mood = .sick
            } else {
                current.hunger = max(0, current.hunger - Int.random(in: 30...50))
                if favoriteTriggered {
                    current.happiness = min(100, current.happiness + 10)
                }
            }
        case .bathe:
            current.cleanliness = 100
        case .play:
            guard PetLogic.canPlay(current) else { toast = "Pet is too tired to play."; return }
            current.happiness = min(100, current.happiness + Int.random(in: 15...20))
            current.energy = max(0, current.energy - 20)
        case .sleep:
            guard PetLogic.canSleep(current) else { toast = "Pet can only sleep when tired."; return }
            current.sleepingUntil = Date().addingTimeInterval(2 * 3600)
            current.energy = 100
        case .cleanup:
            current.muddyPawsActive = false
        case .medicine:
            current.isSick = false
            current.mood = .neutral
        }

        let baseXP: Double
        switch action {
        case .feed, .bathe, .play: baseXP = 15
        case .sleep: baseXP = 10
        case .cleanup: baseXP = 5
        case .medicine: baseXP = 0
        }
        let multiplier = XPCalculator.totalMultiplier(
            rarity: current.rarity,
            favoritismActive: favoriteTriggered,
            premiumActive: premiumActive,
            mood: current.mood,
            isSick: current.isSick
        )
        current.xp += baseXP * multiplier
        while current.xp >= XPCalculator.requiredXP(for: current.level + 1) {
            current.level += 1
        }
        current.mood = PetLogic.mood(for: current)
        current.lastCaredAt = .init()

        do {
            try await service.savePet(current)
            try await service.addActivity(
                petId: current.id,
                actorUserId: current.currentOwnerId,
                content: "\(current.name) got \(action.rawValue)."
            )
            pet = current
            activity = try await service.fetchActivity(petId: current.id, page: 0)
            NotificationCenter.default.post(name: AppNotificationName.petDidUpdate, object: nil)
        } catch {
            toast = error.localizedDescription
        }
    }
}
