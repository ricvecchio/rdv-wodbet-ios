import SwiftUI

struct BetDetailView: View {
    @ObservedObject var viewModel: BetDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var prizeText: String {
        viewModel.bet.prizeType == .other
        ? (viewModel.bet.prizeOtherDescription ?? "Outro")
        : viewModel.bet.prizeType.displayName
    }

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 14) {
                        
                        // Cabeçalho com informações principais
                        GlassCard {
                            VStack(spacing: 12) {
                                Text("Confronto")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                
                                HStack(spacing: 20) {
                                    VStack(spacing: 4) {
                                        Text("👤")
                                            .font(.largeTitle)
                                        Text("Atleta A")
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
                                        Text("Atleta B")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.Colors.textPrimary)
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
                                            title: "Vencedor: A",
                                            isDisabled: viewModel.isWorking,
                                            widthStyle: .custom(140)
                                        ) {
                                            viewModel.proposeWinner(userId: viewModel.bet.athleteAUserId)
                                        }

                                        PrimaryButton(
                                            title: "Vencedor: B",
                                            isDisabled: viewModel.isWorking,
                                            widthStyle: .custom(140)
                                        ) {
                                            viewModel.proposeWinner(userId: viewModel.bet.athleteBUserId)
                                        }
                                    }
                                    .padding(.top, 4)

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
                        
                        // Botão Voltar
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
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity)
                }
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
        .toolbarBackground(.hidden, for: .navigationBar)
        .tint(.white)
        .background(Color.clear)
    }
}
