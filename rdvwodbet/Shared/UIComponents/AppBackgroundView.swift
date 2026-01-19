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

            // leve camada para contraste
            Color.black.opacity(0.10)
                .ignoresSafeArea()

            content
        }
        // ✅ garante que NUNCA pinta branco por trás
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

