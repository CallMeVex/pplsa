import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConstants.supabaseURL,
            supabaseKey: AppConstants.supabaseAnonKey
        )
    }
}
