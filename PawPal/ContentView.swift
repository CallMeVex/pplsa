import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var userVM: UserViewModel

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                if userVM.profile?.onboardingCompleted == true {
                    MainTabView()
                } else {
                    OnboardingFlowView()
                }
            } else {
                WelcomeAuthView()
            }
        }
        .task {
            if authVM.isAuthenticated {
                await userVM.loadCurrentUser()
            }
        }
    }
}
