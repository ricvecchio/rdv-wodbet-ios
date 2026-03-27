import SwiftUI

struct BetDetailView: View {
    @ObservedObject var viewModel: BetDetailViewModel
    @Environment(\.dismiss) private var dismiss

    let athleteAName: String
    let athleteBName: String
    let usersById: [String: AppUser]

    private let detailCardMaxWidth: CGFloat = 340

    private var prizeText: String {
        viewModel.bet.prizeType == .other
        ? (viewModel.bet.prizeOtherDescription ?? "Outro")
        : viewModel.bet.prizeType.displayName
    }

    private var proposedWinnerName: String {
        guard let proposedWinnerUserId = viewModel.bet.proposedWinnerUserId else {
            return "Ainda não definido"
        }

        if proposedWinnerUserId == viewModel.bet.athleteAUserId {
            return athleteAName
        }

        if proposedWinnerUserId == viewModel.bet.athleteBUserId {
            return athleteBName
        }

        return "Ainda não definido"
    }

    private var displayWinnerName: String {
        if let confirmedWinnerUserId = viewModel.bet.confirmedWinnerUserId {
            if confirmedWinnerUserId == viewModel.bet.athleteAUserId {
                return athleteAName
            }

            if confirmedWinnerUserId == viewModel.bet.athleteBUserId {
                return athleteBName
            }
        }

        if let proposedWinnerUserId = viewModel.bet.proposedWinnerUserId {
            if proposedWinnerUserId == viewModel.bet.athleteAUserId {
                return athleteAName
            }

            if proposedWinnerUserId == viewModel.bet.athleteBUserId {
                return athleteBName
            }
        }

        return "Ainda não definido"
    }

    private var athleteAResultText: String {
        let trimmed = viewModel.bet.athleteAResult?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "-" : trimmed
    }

    private var athleteBResultText: String {
        let trimmed = viewModel.bet.athleteBResult?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "-" : trimmed
    }

    var body: some View {
        AppBackgroundView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {

                    // MARK: - Confronto
                    GlassCard {
                        VStack(spacing: 12) {
                            Text("Confronto")
                                .font(.headline)
                                .foregroundColor(.black)

                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("👤")
                                        .font(.largeTitle)

                                    Text(athleteAName)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                .frame(maxWidth: .infinity)

                                Text("VS")
                                    .font(.title2.bold())
                                    .foregroundColor(Theme.Colors.textSecondary)

                                VStack(spacing: 4) {
                                    Text("👤")
                                        .font(.largeTitle)

                                    Text(athleteBName)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(maxWidth: detailCardMaxWidth)

                    // MARK: - Detalhes
                    GlassCard {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Status")
                                    .font(.headline)
                                    .foregroundColor(.black)

                                Spacer()

                                Text(viewModel.bet.status.label)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {

                                HStack {
                                    Text("WOD:")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.black)

                                    Text(viewModel.bet.wodTitle)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }

                                HStack {
                                    Text("Prêmio:")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.black)

                                    Text(prizeText)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }

                                HStack {
                                    Text("Criada em:")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.black)

                                    Text(viewModel.bet.createdAt, style: .date)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }

                                HStack {
                                    Text("Expira em:")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.black)

                                    Text(viewModel.bet.expiresAt, style: .date)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: detailCardMaxWidth)

                    // MARK: - Resultado
                    GlassCard {
                        VStack(spacing: 12) {
                            Text("Resultado")
                                .font(.headline)
                                .foregroundColor(.black)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(athleteAName):")
                                    Text(athleteAResultText)

                                    Spacer()

                                    Text("\(athleteBName):")
                                    Text(athleteBResultText)
                                }
                                .foregroundColor(Theme.Colors.textPrimary)

                                if viewModel.bet.status == .finished {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trophy.fill")
                                            .foregroundColor(.yellow)

                                        Text("Vencedor:")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.black)

                                        Text(displayWinnerName)
                                            .foregroundColor(Theme.Colors.textPrimary)

                                        Spacer()
                                    }
                                } else {
                                    HStack {
                                        Text("Vencedor da aposta:")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.black)

                                        Text(proposedWinnerName)
                                            .foregroundColor(Theme.Colors.textPrimary)

                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: detailCardMaxWidth)

                    // MARK: - Botões
                    HStack(spacing: 10) {

                        if viewModel.currentUser.id == viewModel.bet.createdByUserId,
                           viewModel.bet.status == .open {

                            Button {
                                viewModel.cancel()
                            } label: {
                                Text("Cancelar")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("Voltar")
                                .font(.subheadline.bold())
                                .foregroundColor(Theme.Colors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: detailCardMaxWidth)
                }
                .padding(.horizontal, 10)
            }
        }
    }
}
