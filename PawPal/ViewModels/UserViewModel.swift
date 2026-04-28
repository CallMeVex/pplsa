import Combine
import Foundation
import Supabase

@MainActor
final class UserViewModel: ObservableObject {
    @Published var profile: AppUser?
    @Published var leaderboard: [PublicProfile] = []
    @Published var toast: String?
    @Published var isLoading = false

    private let supabase = SupabaseService.shared.client

    func loadCurrentUser() async {
        guard let authUser = supabase.auth.currentUser else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result: [AppUser] = try await supabase.from("profiles")
                .select()
                .eq("id", value: authUser.id.uuidString)
                .limit(1)
                .execute()
                .value
            profile = result.first
        } catch {
            toast = error.localizedDescription
        }
    }

    func createOrUpdateOnboarding(email: String, username: String, birthday: Date?, gender: String?) async {
        guard let authUser = supabase.auth.currentUser else { return }
        let row = AppUser(
            id: authUser.id,
            email: email,
            username: username,
            bio: nil,
            avatarURL: nil,
            level: 1,
            xp: 0,
            pawsBalance: 0,
            streakCount: 1,
            streakSavers: 0,
            premiumActive: false,
            onboardingCompleted: false,
            createdAt: .init()
        )
        do {
            try await supabase.from("profiles").upsert(row).execute()
            profile = row
        } catch {
            toast = error.localizedDescription
        }
    }

    func setOnboardingCompleted() async {
        guard let userId = profile?.id else { return }
        do {
            try await supabase.from("profiles")
                .update(["onboarding_completed": true])
                .eq("id", value: userId.uuidString)
                .execute()
            profile?.onboardingCompleted = true
        } catch {
            toast = error.localizedDescription
        }
    }

    func checkUsernameAvailability(_ username: String) async -> Bool {
        do {
            let rows: [PublicProfile] = try await supabase.from("public_profiles")
                .select()
                .ilike("username", pattern: username)
                .limit(1)
                .execute()
                .value
            return rows.isEmpty
        } catch {
            return false
        }
    }

    func fetchLeaderboard(page: Int = 0) async {
        let from = page * AppConstants.pageSize
        let to = from + AppConstants.pageSize - 1
        do {
            let rows: [PublicProfile] = try await supabase.from("leaderboard_view")
                .select()
                .range(from: from, to: to)
                .execute()
                .value
            if page == 0 { leaderboard = rows } else { leaderboard += rows }
        } catch {
            toast = error.localizedDescription
        }
    }
}
