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

    private var selectedWinnerName: String {
        guard let selectedWinnerUserId = viewModel.selectedWinnerUserId else {
            return "Ainda não definido"
        }

        if selectedWinnerUserId == viewModel.bet.athleteAUserId {
            return athleteAName
        }

        if selectedWinnerUserId == viewModel.bet.athleteBUserId {
            return athleteBName
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

    private func winnerButtonTitle(for userId: String) -> String {
        userId == viewModel.bet.athleteAUserId ? athleteAName : athleteBName
    }

    private func isWinnerSelected(_ userId: String) -> Bool {
        viewModel.selectedWinnerUserId == userId
    }

    var body: some View {
        AppBackgroundView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
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
                    .frame(maxWidth: detailCardMaxWidth)

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

                                HStack {
                                    Text("Expira em:")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(viewModel.bet.expiresAt, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: detailCardMaxWidth)

                    GlassCard {
                        VStack(spacing: 12) {
                            Text("Resultado")
                                .font(.headline)
                                .foregroundColor(.black)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    Text("\(athleteAName):")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(athleteAResultText)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()

                                    Text("\(athleteBName):")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(athleteBResultText)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }

                                if viewModel.bet.status == .finished {
                                    HStack(spacing: 6) {
                                        Image(systemName: "trophy.fill")
                                            .font(.subheadline)
                                            .foregroundColor(.yellow)

                                        Text("Vencedor:")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.Colors.textSecondary)

                                        Text(displayWinnerName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(Theme.Colors.textPrimary)

                                        Spacer()
                                    }
                                } else {
                                    HStack {
                                        Text("Vencedor da aposta:")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.Colors.textSecondary)

                                        Text(proposedWinnerName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(Theme.Colors.textPrimary)

                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: detailCardMaxWidth)

                    if viewModel.canEditBetResult {
                        GlassCard {
                            VStack(spacing: 12) {
                                Text("Resultado")
                                    .font(.headline)
                                    .foregroundColor(.black)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(athleteAName)")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    TextField("Ex.: 5:45 ou WO", text: $viewModel.athleteAResultInput)
                                        .textInputAutocapitalization(.characters)
                                        .autocorrectionDisabled(true)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.black.opacity(0.18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Theme.Colors.border.opacity(0.7), lineWidth: 1)
                                        )
                                        .cornerRadius(10)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(athleteBName)")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    TextField("Ex.: 6:02 ou WO", text: $viewModel.athleteBResultInput)
                                        .textInputAutocapitalization(.characters)
                                        .autocorrectionDisabled(true)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(Color.black.opacity(0.18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Theme.Colors.border.opacity(0.7), lineWidth: 1)
                                        )
                                        .cornerRadius(10)
                                        .foregroundColor(Theme.Colors.textPrimary)
                                }

                                VStack(spacing: 8) {
                                    Text("Vencedor da aposta")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    HStack(spacing: 10) {
                                        Button {
                                            viewModel.selectWinner(userId: viewModel.bet.athleteAUserId)
                                        } label: {
                                            Text(winnerButtonTitle(for: viewModel.bet.athleteAUserId))
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(Theme.Colors.textPrimary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(
                                                            isWinnerSelected(viewModel.bet.athleteAUserId)
                                                            ? Color.white.opacity(0.20)
                                                            : Color.black.opacity(0.18)
                                                        )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            isWinnerSelected(viewModel.bet.athleteAUserId)
                                                            ? Theme.Colors.textPrimary
                                                            : Theme.Colors.border.opacity(0.7),
                                                            lineWidth: 1
                                                        )
                                                )
                                        }
                                        .disabled(viewModel.isWorking)

                                        Button {
                                            viewModel.selectWinner(userId: viewModel.bet.athleteBUserId)
                                        } label: {
                                            Text(winnerButtonTitle(for: viewModel.bet.athleteBUserId))
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(Theme.Colors.textPrimary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(
                                                            isWinnerSelected(viewModel.bet.athleteBUserId)
                                                            ? Color.white.opacity(0.20)
                                                            : Color.black.opacity(0.18)
                                                        )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            isWinnerSelected(viewModel.bet.athleteBUserId)
                                                            ? Theme.Colors.textPrimary
                                                            : Theme.Colors.border.opacity(0.7),
                                                            lineWidth: 1
                                                        )
                                                )
                                        }
                                        .disabled(viewModel.isWorking)
                                    }
                                }

                                HStack {
                                    Text("Selecionado:")
                                        .font(.footnote)
                                        .foregroundColor(Theme.Colors.textSecondary)

                                    Text(selectedWinnerName)
                                        .font(.footnote.weight(.semibold))
                                        .foregroundColor(Theme.Colors.textPrimary)

                                    Spacer()
                                }

                                PrimaryButton(
                                    title: viewModel.isWorking ? "Salvando..." : "Salvar resultado",
                                    isDisabled: viewModel.isWorking || !viewModel.canSaveBetResult,
                                    widthStyle: .card
                                ) {
                                    viewModel.saveBetResult()
                                }
                            }
                        }
                        .frame(maxWidth: detailCardMaxWidth)
                    }

                    if (viewModel.bet.status == .open || viewModel.bet.status == .disputed),
                       viewModel.isAthlete {

                        GlassCard {
                            VStack(spacing: 12) {
                                Text("Confirmação")
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
                        .frame(maxWidth: detailCardMaxWidth)
                    }

                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundColor(Theme.Colors.error)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.black.opacity(0.55)))
                            .frame(maxWidth: detailCardMaxWidth)
                    }

                    HStack(spacing: 10) {
                        if viewModel.currentUser.id == viewModel.bet.createdByUserId,
                           (viewModel.bet.status == .open || viewModel.bet.status == .disputed) {

                            Button {
                                viewModel.cancel()
                            } label: {
                                Text("Cancelar")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 42)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red)
                                    )
                            }
                            .disabled(viewModel.isWorking)
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("Voltar")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.55))
                                )
                        }
                    }
                    .frame(maxWidth: detailCardMaxWidth)
                    .padding(.top, 10)
                }
                .padding(.top, 12)
                .padding(.bottom, 28)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .clipped()
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
