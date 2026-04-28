import Foundation
import Supabase

@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published var users: [PublicProfile] = []
    @Published var isLoading = false
    @Published var page = 0

    private let supabase = SupabaseService.shared.client

    func refresh() async {
        page = 0
        users = []
        await loadNext()
    }

    func loadNext() async {
        isLoading = true
        defer { isLoading = false }
        let from = page * AppConstants.pageSize
        let to = from + AppConstants.pageSize - 1
        do {
            let rows: [PublicProfile] = try await supabase.from("leaderboard_view")
                .select()
                .range(from: from, to: to)
                .execute()
                .value
            if !rows.isEmpty {
                users += rows
                page += 1
            }
        } catch {
            // Keeps MVP simple; real app should expose an error state.
        }
    }
}
