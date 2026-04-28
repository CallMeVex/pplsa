import AuthenticationServices
import Combine
import CryptoKit
import Foundation

@MainActor
final class AuthViewModel: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: AppUser?

    private let authService = AuthService()
    private var currentNonce: String?

    func bootstrapSession() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let session = try await authService.currentSession() {
                isAuthenticated = true
                RevenueCatService.shared.configure(userId: session.user.id.uuidString)
            } else {
                isAuthenticated = false
            }
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
        }
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signUp(email: email, password: password)
            try await authService.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await authService.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    func handleAppleResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let tokenData = credential.identityToken,
                  let token = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Apple sign-in failed."
                return
            }

            do {
                try await authService.signInWithApple(idToken: token, nonce: nonce)
                isAuthenticated = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if status == errSecSuccess {
                result.append(charset[Int(random) % charset.count])
                remaining -= 1
            }
        }
        return result
    }
}
