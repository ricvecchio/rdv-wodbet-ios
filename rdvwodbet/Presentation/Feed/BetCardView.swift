import SwiftUI

struct BetCardView: View {
    let bet: Bet
    let athleteAName: String
    let athleteBName: String

    private var prizeText: String {
        bet.prizeType == .other
        ? (bet.prizeOtherDescription ?? "Outro")
        : bet.prizeType.displayName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .firstTextBaseline) {
                Text("\(athleteAName) vs \(athleteBName)")
                    .font(.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)

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
        .padding(.vertical,iOS: 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension View {
    /// Pequena proteção: alguns simuladores/targets podem acusar warning com `.padding(.vertical, 6)`
    /// em versões antigas; aqui fica explícito e controlado.
    func padding(_ edges: Edge.Set = .all, iOS value: CGFloat) -> some View {
        self.padding(edges, value)
    }
}

