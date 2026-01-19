import SwiftUI

struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius, style: .continuous)
                    .fill(.regularMaterial)

                RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius, style: .continuous)
                    .fill(Theme.Colors.glassOverlay)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Layout.cardCornerRadius, style: .continuous)
                .stroke(Theme.Colors.border, lineWidth: Theme.Effects.borderLineWidth)
        )
        .shadow(
            color: Theme.Colors.cardShadow,
            radius: Theme.Effects.cardShadowRadius,
            x: 0,
            y: Theme.Effects.cardShadowY
        )
    }
}
