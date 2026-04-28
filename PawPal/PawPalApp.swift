import SwiftUI

@main
struct PawPalApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var userVM = UserViewModel()
    @StateObject private var petVM = PetViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(userVM)
                .environmentObject(petVM)
                .task {
                    await authVM.bootstrapSession()
                    await NotificationService.shared.requestPermission()
                }
        }
    }
}
