import SwiftUI

struct PrimaryButton: View {
    let title: String
    var loading = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if loading { ProgressView().tint(.white) }
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.primary)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
    }
}
