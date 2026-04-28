import AuthenticationServices
import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var petVM: PetViewModel

    @State private var page = 0
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var usernameAvailable: Bool?
    @State private var gender = "Prefer not to say"
    @State private var birthday = Date()
    @State private var selectedSpecies: PetSpecies = .dog
    @State private var petName = ""

    private let genders = ["Male", "Female", "Other", "Prefer not to say"]

    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: Double(page + 1), total: 9).tint(Theme.primary)
            Group {
                switch page {
                case 0: welcomePage
                case 1: accountPage
                case 2: essentialInfoPage
                case 3: chooseEggPage
                case 4: incubationPage
                case 5: hatchPage
                case 6: tutorialPage
                case 7: coparentPage
                default: launchPage
                }
            }
            Spacer()
        }
        .padding()
        .background(Theme.lightBackground.ignoresSafeArea())
    }

    private var welcomePage: some View {
        VStack(spacing: 14) {
            Text("Welcome to PawPal").font(.title.bold())
            Text("A Social World Where Friendship Levels Up — One Paw at a Time")
                .multilineTextAlignment(.center)
            PrimaryButton(title: "Login") { page = 1 }
            PrimaryButton(title: "Sign Up") { page = 1 }
        }
    }

    private var accountPage: some View {
        VStack(spacing: 12) {
            TextField("Email", text: $email).textInputAutocapitalization(.never)
            SecureField("Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)
            SignInWithAppleButton(.continue, onRequest: authVM.makeAppleRequest) { result in
                Task { await authVM.handleAppleResult(result) }
            }
            .frame(height: 45)
            PrimaryButton(title: "Continue") {
                guard !email.isEmpty, !password.isEmpty, password == confirmPassword else { return }
                page = 2
            }
        }
    }

    private var essentialInfoPage: some View {
        VStack(spacing: 12) {
            TextField("Username", text: $username)
                .onChange(of: username) { newValue in
                    Task { usernameAvailable = await userVM.checkUsernameAvailability(newValue) }
                }
            if let usernameAvailable {
                Text(usernameAvailable ? "Username available" : "Username is taken")
                    .foregroundStyle(usernameAvailable ? .green : .red)
            }
            Picker("Gender", selection: $gender) {
                ForEach(genders, id: \.self, content: Text.init)
            }
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            PrimaryButton(title: "Continue") { page = 3 }
        }
    }

    private var chooseEggPage: some View {
        VStack(spacing: 12) {
            Text("Choose first egg").font(.title2.bold())
            HStack {
                eggCard(.dog, title: "Dog")
                eggCard(.cat, title: "Cat")
                eggCard(.parrot, title: "Parrot")
            }
            PrimaryButton(title: "Hatch My Egg!") { page = 4 }
        }
    }

    private var incubationPage: some View {
        VStack(spacing: 12) {
            Image(systemName: "hourglass").font(.largeTitle).symbolEffect(.pulse)
            Text("Your egg will hatch in 24 hours")
            PrimaryButton(title: "Explore PawPal") { page = 5 }
            Button("Skip") { page = 5 }
        }
    }

    private var hatchPage: some View {
        VStack(spacing: 12) {
            Text("Your \(selectedSpecies.rawValue.capitalized) hatched!").font(.title3.bold())
            TextField("Pet Name", text: $petName)
            PrimaryButton(title: "Continue") {
                Task {
                    guard let ownerId = userVM.profile?.id else { return }
                    await petVM.hatchStarterPet(ownerId: ownerId, name: petName, species: selectedSpecies)
                    page = 6
                }
            }
        }
    }

    private var tutorialPage: some View {
        VStack(spacing: 12) {
            Text("Pet care tutorial").font(.title3.bold())
            Text("Tap actions to gain XP (+15 each)")
            HStack {
                Button("Feed +15 XP") { Task { await petVM.perform(action: .feed, premiumActive: userVM.profile?.premiumActive == true) } }
                Button("Bathe +15 XP") { Task { await petVM.perform(action: .bathe, premiumActive: userVM.profile?.premiumActive == true) } }
            }
            Text("You've reached Level 1!")
            PrimaryButton(title: "Continue") { page = 7 }
        }
    }

    private var coparentPage: some View {
        VStack(spacing: 12) {
            Text("Invite a co-parent").font(.title3.bold())
            TextField("Search username", text: .constant(""))
            PrimaryButton(title: "Skip for now") { page = 8 }
        }
    }

    private var launchPage: some View {
        VStack(spacing: 12) {
            Text("Ready to explore PawPal!").font(.title2.bold())
            Text("Tooltips will highlight key features in the app.")
            PrimaryButton(title: "Open App") {
                Task {
                    await userVM.createOrUpdateOnboarding(email: email, username: username, birthday: birthday, gender: gender)
                    await userVM.setOnboardingCompleted()
                }
            }
        }
    }

    private func eggCard(_ species: PetSpecies, title: String) -> some View {
        VStack {
            Image(systemName: "circle.dashed")
                .font(.largeTitle)
                .scaleEffect(selectedSpecies == species ? 1.1 : 1.0)
                .animation(.spring(), value: selectedSpecies)
            Text(title)
        }
        .padding()
        .background(selectedSpecies == species ? Theme.primary.opacity(0.2) : .white)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .onTapGesture { withAnimation(.spring()) { selectedSpecies = species } }
    }
}
