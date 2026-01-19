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
        .frame(maxWidth: Theme.Layout.cardMaxWidth)
        .padding(Theme.Layout.cardPadding)
        .background(
            ZStack {
                // 🔥 Glass base
                RoundedRectangle(
                    cornerRadius: Theme.Layout.cardCornerRadius,
                    style: .continuous
                )
                .fill(.regularMaterial)

                // 🔥 Overlay escuro para contraste (seu padrão final)
                RoundedRectangle(
                    cornerRadius: Theme.Layout.cardCornerRadius,
                    style: .continuous
                )
                .fill(Theme.Colors.glassOverlay)
            }
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: Theme.Layout.cardCornerRadius,
                style: .continuous
            )
            .stroke(Theme.Colors.border, lineWidth: Theme.Effects.borderLineWidth)
        )
        .shadow(
            color: Theme.Colors.cardShadow,
            radius: Theme.Effects.cardShadowRadius,
            x: 0,
            y: Theme.Effects.cardShadowY
        )
        .padding(.horizontal, Theme.Layout.cardHorizontalMargin)
    }
}

