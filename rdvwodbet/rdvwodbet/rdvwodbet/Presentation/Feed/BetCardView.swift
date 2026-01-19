import SwiftUI

struct BetCardView: View {
    let bet: Bet

    private var prizeText: String {
        bet.prizeType == .other
        ? (bet.prizeOtherDescription ?? "Outro")
        : bet.prizeType.displayName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .firstTextBaseline) {
                Text("A vs B")
                    .font(.headline)
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                Text(bet.status.label)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.25))
                    )
            }

            Text("WOD: \(bet.wodTitle)")
                .font(.subheadline)
                .foregroundColor(Theme.Colors.textPrimary)

            Text("Prêmio: \(prizeText)")
                .font(.footnote)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
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
        .padding(.vertical, 6) // respiro entre cards no feed
    }
}

