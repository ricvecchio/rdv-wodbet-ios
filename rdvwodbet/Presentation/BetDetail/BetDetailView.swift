import SwiftUI

struct BetDetailView: View {
    @ObservedObject var viewModel: BetDetailViewModel
    @Environment(\.dismiss) private var dismiss

    let athleteAName: String
    let athleteBName: String

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

    private var confirmedWinnerName: String {
        guard let confirmedWinnerUserId = viewModel.bet.confirmedWinnerUserId else {
            return "Ainda não confirmado"
        }

        if confirmedWinnerUserId == viewModel.bet.athleteAUserId {
            return athleteAName
        }

        if confirmedWinnerUserId == viewModel.bet.athleteBUserId {
            return athleteBName
        }

        return "Ainda não confirmado"
    }

    private func confirmationLabel(forAthleteConfirmed isConfirmed: Bool) -> String {
        isConfirmed ? "✅ Confirmado" : "⏳ Aguardando"
    }

    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: 14) {

                    GlassCard {
                        VStack(spacing: 12) {
                            Text("Confronto")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)

                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("👤")
                                        .font(.largeTitle)

                                    Text(athleteAName)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                        .lineLimit(1)
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
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    GlassCard {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Status")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Spacer()

                                Text(viewModel.bet.status.label)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.black.opacity(0.25))
                                    )
                            }

                            Divider()
                                .background(Theme.Colors.border)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("WOD:")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(viewModel.bet.wodTitle)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }

                                HStack {
                                    Text("Prêmio:")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(prizeText)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }

                                HStack {
                                    Text("Criada em:")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(viewModel.bet.createdAt, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Andamento do Resultado")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)

                            HStack {
                                Text("Vencedor proposto:")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)

                                Text(proposedWinnerName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Spacer()
                            }

                            HStack {
                                Text("Vencedor confirmado:")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.Colors.textSecondary)

                                Text(confirmedWinnerName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Spacer()
                            }

                            Divider()
                                .background(Theme.Colors.border)

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("\(athleteAName):")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(confirmationLabel(forAthleteConfirmed: viewModel.bet.athleteAConfirmed))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }

                                HStack {
                                    Text("\(athleteBName):")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(confirmationLabel(forAthleteConfirmed: viewModel.bet.athleteBConfirmed))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }
                            }
                        }
                    }

                    if (viewModel.bet.status == .open || viewModel.bet.status == .disputed),
                       viewModel.isAthlete {

                        GlassCard {
                            VStack(spacing: 12) {
                                Text("Resultado")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Text("Escolha o vencedor proposto:")
                                    .font(.footnote)
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)

                                HStack(spacing: 10) {
                                    PrimaryButton(
                                        title: "Vencedor: \(athleteAName)",
                                        isDisabled: viewModel.isWorking,
                                        widthStyle: .custom(140)
                                    ) {
                                        viewModel.proposeWinner(userId: viewModel.bet.athleteAUserId)
                                    }

                                    PrimaryButton(
                                        title: "Vencedor: \(athleteBName)",
                                        isDisabled: viewModel.isWorking,
                                        widthStyle: .custom(140)
                                    ) {
                                        viewModel.proposeWinner(userId: viewModel.bet.athleteBUserId)
                                    }
                                }
                                .padding(.top, 4)

                                PrimaryButton(
                                    title: viewModel.isWorking
                                        ? "Confirmando..."
                                        : (viewModel.currentUserAlreadyConfirmed ? "Já confirmado" : "Confirmar"),
                                    isDisabled: viewModel.isWorking || !viewModel.canConfirmResult || viewModel.currentUserAlreadyConfirmed,
                                    widthStyle: .card
                                ) {
                                    viewModel.confirm()
                                }
                                .padding(.top, 8)

                                if !viewModel.canConfirmResult {
                                    Text("Escolha um vencedor antes de confirmar o resultado.")
                                        .font(.footnote)
                                        .foregroundColor(Theme.Colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }

                                Button(role: .destructive) {
                                    viewModel.reject()
                                } label: {
                                    Text("Rejeitar resultado proposto")
                                        .font(.footnote)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                }
                                .disabled(viewModel.isWorking)
                                .padding(.top, 4)
                            }
                        }
                    }

                    if viewModel.currentUser.id == viewModel.bet.createdByUserId,
                       (viewModel.bet.status == .open || viewModel.bet.status == .disputed) {

                        GlassCard {
                            VStack(spacing: 8) {
                                Text("Ações do Criador")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.textPrimary)

                                Button(role: .destructive) {
                                    viewModel.cancel()
                                } label: {
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Cancelar aposta")
                                    }
                                    .font(.subheadline)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                }
                                .disabled(viewModel.isWorking)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                    }

                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(Theme.Colors.error)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.black.opacity(0.55)))
                            .frame(maxWidth: Theme.Layout.cardMaxWidth)
                    }

                    PrimaryButton(
                        title: "Voltar",
                        isDisabled: false,
                        widthStyle: .card
                    ) {
                        dismiss()
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: Theme.Layout.cardMaxWidth)
                .padding(.top, Theme.Layout.screenContentTopPadding)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Detalhes da Aposta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.headline)

                        Text("Voltar")
                            .font(.subheadline)
                    }
                    .foregroundColor(Theme.Colors.textPrimary)
                }
            }
        }
        .appNavigationBarStyle()
        .background(Color.clear)
    }
}
