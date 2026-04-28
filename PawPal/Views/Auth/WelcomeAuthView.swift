import AuthenticationServices
import SwiftUI

struct WelcomeAuthView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Theme.lightBackground.ignoresSafeArea()
                VStack(spacing: 18) {
                    Spacer()
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(Theme.primary)
                    Text("PawPal")
                        .font(.largeTitle.bold())
                    Text("A Social World Where Friendship Levels Up — One Paw at a Time")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    VStack(spacing: 12) {
                        TextField("Email", text: $email).textInputAutocapitalization(.never)
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    PrimaryButton(title: "Login", loading: authVM.isLoading) {
                        Task { await authVM.signIn(email: email, password: password) }
                    }
                    PrimaryButton(title: "Sign Up", loading: authVM.isLoading) {
                        Task { await authVM.signUp(email: email, password: password) }
                    }
                    SignInWithAppleButton(.signIn, onRequest: authVM.makeAppleRequest) { result in
                        Task { await authVM.handleAppleResult(result) }
                    }
                    .frame(height: 48)
                    Spacer()
                }
                .padding()

                if let message = authVM.errorMessage {
                    ToastView(message: message).padding(.bottom, 20)
                }
            }
        }
    }
}
