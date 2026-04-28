import AuthenticationServices
import Foundation
import Supabase

final class AuthService {
    private let supabase = SupabaseService.shared.client

    func signUp(email: String, password: String) async throws {
        do {
            _ = try await supabase.auth.signUp(email: email, password: password)
        } catch {
            throw error
        }
    }

    func signIn(email: String, password: String) async throws {
        do {
            _ = try await supabase.auth.signIn(email: email, password: password)
        } catch {
            throw error
        }
    }

    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
        } catch {
            throw error
        }
    }

    func currentSession() async throws -> Session? {
        do {
            return try await supabase.auth.session
        } catch {
            throw error
        }
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        do {
            _ = try await supabase.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
            )
        } catch {
            throw error
        }
    }

    func updatePassword(_ password: String) async throws {
        do {
            try await supabase.auth.update(user: UserAttributes(password: password))
        } catch {
            throw error
        }
    }

    func deleteAccount() async throws {
        // Should invoke privileged edge function in production; MVP keeps a placeholder.
        guard let user = supabase.auth.currentUser else { return }
        do {
            try await supabase.from("profiles").delete().eq("id", value: user.id).execute()
        } catch {
            throw error
        }
    }
}
