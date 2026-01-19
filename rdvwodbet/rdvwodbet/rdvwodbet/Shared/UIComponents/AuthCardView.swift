import SwiftUI

struct AuthCardView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .frame(maxWidth: 300)
        .padding(16)
        .background(
            ZStack {
                // 🔥 Glass base (mais denso)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)

                // 🔥 Overlay escuro para contraste
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.45))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.30),
            radius: 16,
            x: 0,
            y: 10
        )
        .padding(.horizontal, 24)
    }
}

