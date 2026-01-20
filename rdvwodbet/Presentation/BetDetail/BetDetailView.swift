import SwiftUI

struct BetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BetDetailViewModel

    private let barHeight: CGFloat = 52

    private var prizeText: String {
        viewModel.bet.prizeType == .other
        ? (viewModel.bet.prizeOtherDescription ?? "Outro")
        : viewModel.bet.prizeType.displayName
    }

    var body: some View {
        AppBackgroundView {
            GeometryReader { proxy in
                let topInset = proxy.safeAreaInsets.top
                let totalTop = topInset + barHeight

                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: totalTop)

                        contentView
                    }

                    topBar(topInset: topInset)
                }
                .ignoresSafeArea()
                // ✅ mata a navbar nativa e garante que você nunca “fica preso”
                .toolbar(.hidden, for: .navigationBar)
            }
        }
        .tint(.white)
    }

    // MARK: - Content

    private var contentView: some View {
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

                            HStack(spacing: 12) {
                                PrimaryButton(
                                    title: "Vencedor: A",
                                    isDisabled: viewModel.isWorking,
                                    widthStyle: .fill
                                ) {
                                    viewModel.proposeWinner(userId: viewModel.bet.athleteAUserId)
                                }

                                PrimaryButton(
                                    title: "Vencedor: B",
                                    isDisabled: viewModel.isWorking,
                                    widthStyle: .fill
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
            .background(Color.clear)
        }
    }

    // MARK: - TopBar

    private func topBar(topInset: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            Rectangle()
                .fill(Color.black.opacity(0.55))

            Rectangle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)

            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                }

                Spacer()

                Text("Aposta")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Spacer()

                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: barHeight)
        .padding(.top, topInset)
    }
}

