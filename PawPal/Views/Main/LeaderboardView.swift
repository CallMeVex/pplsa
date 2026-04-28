import SwiftUI

struct LeaderboardView: View {
    @StateObject private var vm = LeaderboardViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(vm.users.enumerated()), id: \.element.id) { index, user in
                    HStack {
                        Text("#\(index + 1)").font(.headline)
                        VStack(alignment: .leading) {
                            Text(user.username).fontWeight(.semibold)
                            Text(user.levelTitle).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("Lv \(user.level)")
                    }
                    .onAppear {
                        if index == vm.users.count - 1 {
                            Task { await vm.loadNext() }
                        }
                    }
                }
                if vm.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Leaderboard")
            .task { await vm.refresh() }
        }
    }
}
