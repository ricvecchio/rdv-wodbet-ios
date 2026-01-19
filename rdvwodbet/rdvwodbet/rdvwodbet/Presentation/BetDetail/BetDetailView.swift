import SwiftUI

struct BetDetailView: View {
    @ObservedObject var viewModel: BetDetailViewModel

    private var prizeText: String {
        viewModel.bet.prizeType == .other
        ? (viewModel.bet.prizeOtherDescription ?? "Outro")
        : viewModel.bet.prizeType.displayName
    }

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {

                    GlassCard {
                        Text("Status")
                            .font(.headline)
                            .foregroundColor(Theme.Colors.textPrimary)

                        Text(viewModel.bet.status.label)
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }

                    GlassCard {
                        Text("Detalhes")
                            .font(.headline)
                            .foregroundColor(Theme.Colors.textPrimary)

                        Text("WOD: \(viewModel.bet.wodTitle)")
                            .foregroundColor(Theme.Colors.textPrimary)

                        Text("Prêmio: \(prizeText)")
                            .font(.footnote)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }

                    if (viewModel.bet.status == .open || viewModel.bet.status == .disputed),
                       viewModel.isAthlete {

                        GlassCard {
                            Text("Resultado")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)

                            Text("Escolha o vencedor proposto:")
                                .font(.footnote)
                                .foregroundColor(Theme.Colors.textSecondary)

                            HStack(spacing: 10) {
                                PrimaryButton(
                                    title: "Vencedor: A",
                                    isDisabled: viewModel.isWorking,
                                    widthStyle: .custom(145)
                                ) {
                                    viewModel.proposeWinner(userId: viewModel.bet.athleteAUserId)
                                }

                                PrimaryButton(
                                    title: "Vencedor: B",
                                    isDisabled: viewModel.isWorking,
                                    widthStyle: .custom(145)
                                ) {
                                    viewModel.proposeWinner(userId: viewModel.bet.athleteBUserId)
                                }
                            }

                            PrimaryButton(
                                title: viewModel.isWorking ? "Confirmando..." : "Confirmar",
                                isDisabled: viewModel.isWorking,
                                widthStyle: .card
                            ) {
                                viewModel.confirm()
                            }
                            .padding(.top, 8)

                            Button(role: .destructive) {
                                viewModel.reject()
                            } label: {
                                Text("Rejeitar resultado proposto")
                            }
                            .disabled(viewModel.isWorking)
                            .padding(.top, 4)
                        }
                    }

                    if viewModel.currentUser.id == viewModel.bet.createdByUserId,
                       (viewModel.bet.status == .open || viewModel.bet.status == .disputed) {

                        GlassCard {
                            Button(role: .destructive) {
                                viewModel.cancel()
                            } label: {
                                Text("Cancelar aposta")
                            }
                            .disabled(viewModel.isWorking)
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
                }
                .frame(maxWidth: Theme.Layout.cardMaxWidth)
                .padding(.top, 16)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Aposta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .tint(.white)
        .background(Color.clear)
    }
}

