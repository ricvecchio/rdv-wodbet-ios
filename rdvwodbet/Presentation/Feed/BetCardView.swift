import SwiftUI

struct BetCardView: View {
    let bet: Bet
    let athleteAName: String
    let athleteBName: String
    let currentUserId: String
    let onVote: (String) -> Void

    private var prizeText: String {
        bet.prizeType == .other
        ? (bet.prizeOtherDescription ?? "Outro")
        : bet.prizeType.displayName
    }

    private func isSelected(_ athleteId: String) -> Bool {
        bet.voteOfUser(currentUserId) == athleteId
    }

    private func percentageText(for athleteId: String) -> String {
        "\(bet.votePercentage(for: athleteId))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(athleteAName) & \(athleteBName)")
                .font(.headline.bold())
                .foregroundColor(.black)
                .lineLimit(1)

            infoRow(label: "Status", value: bet.status.label)
            infoRow(label: "WOD", value: bet.wodTitle)
            infoRow(label: "Prêmio", value: prizeText)

            HStack(spacing: 10) {
                voteButton(
                    athleteName: athleteAName,
                    athleteId: bet.athleteAUserId
                )

                voteButton(
                    athleteName: athleteBName,
                    athleteId: bet.athleteBUserId
                )
            }
            .padding(.top, 2)
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
        .padding(.vertical, iOS: 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text("\(label):")
                .font(.subheadline.bold())
                .foregroundColor(.black)

            Text(value)
                .font(.subheadline)
                .foregroundColor(Theme.Colors.textPrimary)

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func voteButton(
        athleteName: String,
        athleteId: String
    ) -> some View {
        let selected = isSelected(athleteId)

        Button {
            onVote(athleteId)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(selected ? .green : Theme.Colors.textPrimary)

                Text(athleteName)
                    .font(.caption)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)

                Text(percentageText(for: athleteId))
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(selected ? Color.green.opacity(0.22) : Color.black.opacity(0.20))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(selected ? Color.green.opacity(0.7) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private extension View {
    func padding(_ edges: Edge.Set = .all, iOS value: CGFloat) -> some View {
        self.padding(edges, value)
    }
}
