import SwiftUI

struct BetCardView: View {
    let bet: Bet

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("A vs B")
                    .font(.headline)
                Spacer()
                Text(bet.status.label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("WOD: \(bet.wodTitle)")
                .font(.subheadline)

            let prize = bet.prizeType == .other ? (bet.prizeOtherDescription ?? "Outro") : bet.prizeType.displayName
            Text("Prêmio: \(prize)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
