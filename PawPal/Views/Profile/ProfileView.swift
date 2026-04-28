import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @State private var bio = ""
    @State private var newPassword = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                if let user = userVM.profile {
                    Image(systemName: "person.crop.circle.fill").font(.system(size: 64))
                    Text(user.username).font(.title2.bold())
                    Text(XPCalculator.levelTitle(for: user.level)).foregroundStyle(.secondary)
                    ProgressView(value: user.xp, total: XPCalculator.requiredXP(for: user.level + 1)) {
                        Text("XP")
                    }
                    Text("🔥 \(user.streakCount)  •  🐾 \(user.pawsBalance)")
                    TextEditor(text: $bio)
                        .frame(height: 80)
                        .padding(8)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }
                SecureField("New password", text: $newPassword)
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                PrimaryButton(title: "Change Password") {
                    Task { try? await AuthService().updatePassword(newPassword) }
                }
                PrimaryButton(title: "Logout") { Task { await authVM.signOut() } }
                PrimaryButton(title: "Delete Account") { Task { try? await AuthService().deleteAccount() } }
                Spacer()
            }
            .padding()
            .background(Theme.lightBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .task { await userVM.loadCurrentUser() }
        }
    }
}
