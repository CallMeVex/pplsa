import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Theme.dark.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(radius: 4)
    }
}
