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

    private var isVotingEnabled: Bool {
        bet.status == .open || bet.status == .disputed
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
        .padding(.vertical, iOS: 6)
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
        let percentage = max(bet.votePercentage(for: athleteId), selected ? 8 : 0)
        let fillOpacity: Double = selected ? 0.32 : (isVotingEnabled ? 0.18 : 0.10)
        let borderOpacity: Double = selected ? 0.80 : 0.0

        Button {
            if isVotingEnabled {
                onVote(athleteId)
            }
        } label: {
            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    let width = geometry.size.width * CGFloat(percentage) / 100

                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(selected ? Color.green.opacity(fillOpacity) : Color.white.opacity(fillOpacity))
                        .frame(width: max(width, 0))
                }

                HStack(spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(
                            selected
                            ? .green
                            : (isVotingEnabled ? Theme.Colors.textPrimary : .gray.opacity(0.5))
                        )

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
                        .foregroundColor(Theme.Colors.textPrimary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isVotingEnabled ? Color.black.opacity(0.26) : Color.black.opacity(0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        selected ? Color.green.opacity(borderOpacity) : Color.white.opacity(0.06),
                        lineWidth: selected ? 1.2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isVotingEnabled)
        .opacity(isVotingEnabled ? 1.0 : 0.72)
    }
}

private extension View {
    func padding(_ edges: Edge.Set = .all, iOS value: CGFloat) -> some View {
        self.padding(edges, value)
    }
}
