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

    private var athleteAPercentage: Int {
        bet.votePercentage(for: bet.athleteAUserId)
    }

    private var athleteBPercentage: Int {
        bet.votePercentage(for: bet.athleteBUserId)
    }

    private func isSelected(_ athleteId: String) -> Bool {
        bet.voteOfUser(currentUserId) == athleteId
    }

    private func percentageText(for athleteId: String) -> String {
        "\(bet.votePercentage(for: athleteId))%"
    }

    private var isVotingEnabled: Bool {
        bet.status == .open || bet.status == .disputed
    }

    private func fillColor(for athleteId: String) -> Color {
        let current = bet.votePercentage(for: athleteId)
        let other = athleteId == bet.athleteAUserId ? athleteBPercentage : athleteAPercentage

        if current > other {
            return Color.green.opacity(0.28)
        } else if current < other {
            return Color.red.opacity(0.24)
        } else {
            return Color.black.opacity(0.30)
        }
    }

    private func borderColor(for athleteId: String) -> Color {
        if isSelected(athleteId) {
            return Color.green.opacity(0.75)
        }

        let current = bet.votePercentage(for: athleteId)
        let other = athleteId == bet.athleteAUserId ? athleteBPercentage : athleteAPercentage

        if current > other {
            return Color.green.opacity(0.45)
        } else if current < other {
            return Color.red.opacity(0.35)
        } else {
            return Color.clear
        }
    }

    private func iconColor(for athleteId: String) -> Color {
        if isSelected(athleteId) {
            return .green
        }

        let current = bet.votePercentage(for: athleteId)
        let other = athleteId == bet.athleteAUserId ? athleteBPercentage : athleteAPercentage

        if current > other {
            return Color.green.opacity(0.9)
        } else if current < other {
            return Color.red.opacity(0.8)
        } else {
            return isVotingEnabled ? Theme.Colors.textPrimary : .gray.opacity(0.5)
        }
    }

    private func percentageColor(for athleteId: String) -> Color {
        let current = bet.votePercentage(for: athleteId)
        let other = athleteId == bet.athleteAUserId ? athleteBPercentage : athleteAPercentage

        if current > other {
            return Color.green.opacity(0.95)
        } else if current < other {
            return Color.red.opacity(0.9)
        } else {
            return Theme.Colors.textPrimary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(athleteAName) & \(athleteBName)")
                .font(.headline.bold())
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            dividerHighlight()

            infoRow(label: "Status", value: bet.status.label)
            infoRow(label: "WOD", value: bet.wodTitle)
            infoRow(label: "Prêmio", value: prizeText)

            VStack(spacing: 8) {
                pollRow(
                    athleteName: athleteAName,
                    athleteId: bet.athleteAUserId
                )

                pollRow(
                    athleteName: athleteBName,
                    athleteId: bet.athleteBUserId
                )
            }
            .padding(.top, 4)
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
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func dividerHighlight() -> some View {
        VStack(spacing: 4) {
            Rectangle()
                .fill(Color.black.opacity(0.18))
                .frame(height: 1)

            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
        }
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
    private func pollRow(
        athleteName: String,
        athleteId: String
    ) -> some View {
        let selected = isSelected(athleteId)

        Button {
            if isVotingEnabled {
                onVote(athleteId)
            }
        } label: {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(fillColor(for: athleteId))

                HStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(iconColor(for: athleteId))

                    Text(athleteName)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(
                            isVotingEnabled
                            ? Theme.Colors.textPrimary
                            : .gray.opacity(0.6)
                        )
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text(percentageText(for: athleteId))
                        .font(.caption2.weight(.bold))
                        .foregroundColor(percentageColor(for: athleteId))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(height: 34)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        selected ? Color.green.opacity(0.85) : borderColor(for: athleteId),
                        lineWidth: selected ? 1.3 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isVotingEnabled)
        .opacity(isVotingEnabled ? 1.0 : 0.72)
    }
}
