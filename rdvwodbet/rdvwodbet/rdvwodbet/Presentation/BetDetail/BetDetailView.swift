import SwiftUI

struct BetDetailView: View {
    @ObservedObject var viewModel: BetDetailViewModel

    var body: some View {
        Form {
            Section("Status") {
                Text(viewModel.bet.status.label)
            }

            Section("Detalhes") {
                Text("WOD: \(viewModel.bet.wodTitle)")

                let prize = viewModel.bet.prizeType == .other
                    ? (viewModel.bet.prizeOtherDescription ?? "Outro")
                    : viewModel.bet.prizeType.displayName

                Text("Prêmio: \(prize)")
            }

            if viewModel.bet.status == .open || viewModel.bet.status == .disputed {
                if viewModel.isAthlete {
                    Section("Resultado") {
                        Text("Escolha o vencedor proposto:")
                            .font(.subheadline)

                        HStack {
                            Button("Vencedor: A") {
                                viewModel.proposeWinner(userId: viewModel.bet.athleteAUserId)
                            }
                            Spacer()
                            Button("Vencedor: B") {
                                viewModel.proposeWinner(userId: viewModel.bet.athleteBUserId)
                            }
                        }

                        Divider()

                        PrimaryButton(
                            title: viewModel.isWorking ? "Confirmando..." : "Confirmar",
                            isDisabled: viewModel.isWorking
                        ) {
                            viewModel.confirm()
                        }

                        Button(role: .destructive) {
                            viewModel.reject()
                        } label: {
                            Text("Rejeitar resultado proposto")
                        }
                        .disabled(viewModel.isWorking)
                    }
                }

                if viewModel.currentUser.id == viewModel.bet.createdByUserId {
                    Section {
                        Button(role: .destructive) {
                            viewModel.cancel()
                        } label: {
                            Text("Cancelar aposta")
                        }
                        .disabled(viewModel.isWorking)
                    }
                }
            }

            if let msg = viewModel.errorMessage {
                Text(msg).foregroundStyle(.red)
            }
        }
        .scrollContentBackground(.hidden) // 🔥 remove branco do Form
        .navigationTitle("Aposta")
    }
}

