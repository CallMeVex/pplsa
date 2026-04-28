import SwiftUI

struct PetRoomView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var petVM: PetViewModel
    @State private var showToast = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Theme.lightBackground.ignoresSafeArea()
                VStack(spacing: 14) {
                    if let pet = petVM.pet {
                        VStack(spacing: 8) {
                            Text(pet.name).font(.title.bold())
                            Text("\(pet.species.rawValue.capitalized) • \(pet.mood.rawValue.capitalized)")
                            ProgressView(value: Double(pet.happiness), total: 100) { Text("Happiness") }
                            ProgressView(value: Double(pet.hunger), total: 100) { Text("Hunger") }
                            ProgressView(value: Double(pet.cleanliness), total: 100) { Text("Cleanliness") }
                            ProgressView(value: Double(pet.energy), total: 100) { Text("Energy") }
                        }
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .shadow(radius: 2)

                        HStack {
                            actionButton("Feed", icon: "fork.knife", .feed)
                            actionButton("Bathe", icon: "drop.fill", .bathe)
                            actionButton("Play", icon: "soccerball", .play)
                            actionButton("Sleep", icon: "bed.double.fill", .sleep)
                        }
                        if pet.muddyPawsActive {
                            PrimaryButton(title: "Clean Up") {
                                Task { await petVM.perform(action: .cleanup, premiumActive: userVM.profile?.premiumActive == true) }
                            }
                        }
                    } else {
                        VStack {
                            Image(systemName: "bed.double.fill").font(.largeTitle)
                            Text("Your pet is visiting your co-parent.")
                            Text("Bed is ready, toys are scattered, waiting for return.")
                        }
                    }

                    List(petVM.activity) { item in
                        Text(item.content)
                    }
                }
                .padding()

                if showToast, let toast = petVM.toast {
                    ToastView(message: toast).padding(.bottom, 20)
                }
            }
            .navigationTitle("Pets")
            .task {
                if let user = userVM.profile {
                    await petVM.loadPet(for: user.id)
                }
            }
            .onChange(of: petVM.toast) { _ in
                withAnimation(.easeInOut(duration: 0.3)) { showToast = true }
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation(.easeInOut(duration: 0.3)) { showToast = false }
                }
            }
        }
    }

    private func actionButton(_ title: String, icon: String, _ action: CareAction) -> some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            Task { await petVM.perform(action: action, premiumActive: userVM.profile?.premiumActive == true) }
        } label: {
            VStack {
                Image(systemName: icon)
                Text(title).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }
}
