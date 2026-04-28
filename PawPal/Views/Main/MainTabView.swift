import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PetRoomView()
                .tabItem { Label("Pets", systemImage: "pawprint.fill") }
            LeaderboardView()
                .tabItem { Label("Leaderboard", systemImage: "trophy.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
    }
}
