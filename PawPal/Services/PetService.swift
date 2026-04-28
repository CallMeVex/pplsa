import Foundation
import Supabase

final class PetService {
    private let supabase = SupabaseService.shared.client

    func fetchCurrentPet(for userId: UUID) async throws -> Pet? {
        do {
            let response: [Pet] = try await supabase.from("pets")
                .select()
                .eq("current_owner_id", value: userId.uuidString)
                .order("updated_at", ascending: false)
                .limit(1)
                .execute()
                .value
            return response.first
        } catch {
            throw error
        }
    }

    func savePet(_ pet: Pet) async throws {
        do {
            try await supabase.from("pets").upsert(pet).execute()
        } catch {
            throw error
        }
    }

    func addActivity(petId: UUID, actorUserId: UUID?, content: String) async throws {
        let message = ActivityMessage(id: UUID(), petId: petId, actorUserId: actorUserId, content: content, createdAt: .init())
        do {
            try await supabase.from("activity_messages").insert(message).execute()
        } catch {
            throw error
        }
    }

    func fetchActivity(petId: UUID, page: Int) async throws -> [ActivityMessage] {
        let from = page * AppConstants.pageSize
        let to = from + AppConstants.pageSize - 1
        do {
            let response: [ActivityMessage] = try await supabase.from("activity_messages")
                .select()
                .eq("pet_id", value: petId.uuidString)
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value
            return response
        } catch {
            throw error
        }
    }
}
