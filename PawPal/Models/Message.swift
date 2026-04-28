import Foundation

struct ActivityMessage: Codable, Identifiable, Equatable {
    let id: UUID
    let petId: UUID
    let actorUserId: UUID?
    let content: String
    let createdAt: Date
}
