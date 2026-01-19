import SwiftUI

struct AppBackgroundView<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Image("rdv_wodbet_fundo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Overlay para contraste (deixa o app legível)
            LinearGradient(
                colors: [
                    Color.black.opacity(0.40),
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.40)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content
        }
    }
}
