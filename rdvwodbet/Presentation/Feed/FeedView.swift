import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    let container: AppDIContainer

    @State private var showCreate = false

    private let barHeight: CGFloat = 52

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                GeometryReader { proxy in
                    let topInset = proxy.safeAreaInsets.top
                    let totalTop = topInset + barHeight

                    ZStack(alignment: .top) {
                        // Conteúdo com espaço reservado pro header
                        VStack(spacing: 0) {
                            Color.clear.frame(height: totalTop)

                            contentView
                        }

                        topBar(topInset: topInset)
                    }
                    .ignoresSafeArea()
                    // ✅ mata a navbar nativa definitivamente (sem “cabeçalho gigante”)
                    .toolbar(.hidden, for: .navigationBar)
                    .sheet(isPresented: $showCreate) {
                        AppBackgroundView {
                            CreateBetView(
                                viewModel: CreateBetViewModel(
                                    currentUser: viewModel.currentUser,
                                    userRepository: container.userRepository,
                                    createBetUseCase: container.createBetUseCase
                                )
                            )
                        }
                    }
                }
            }
        }
        .tint(.white)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            if viewModel.bets.isEmpty {
                ScrollView {
                    VStack(spacing: 14) {
                        Spacer(minLength: 24)

                        GlassCard {
                            Text("Nenhuma aposta por aqui ainda.")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            Text("Crie a primeira aposta do WOD do dia 😄")
                                .font(.footnote)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            PrimaryButton(
                                title: "Criar aposta",
                                isDisabled: false,
                                widthStyle: .card
                            ) {
                                showCreate = true
                            }
                            .padding(.top, 8)
                        }

                        Spacer(minLength: 24)
                    }
                    .frame(maxWidth: Theme.Layout.cardMaxWidth)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .background(Color.clear)

            } else {
                List {
                    ForEach(viewModel.bets) { bet in
                        NavigationLink {
                            BetDetailView(
                                viewModel: BetDetailViewModel(
                                    bet: bet,
                                    currentUser: viewModel.currentUser,
                                    proposeWinnerUseCase: container.proposeWinnerUseCase,
                                    confirmWinnerUseCase: container.confirmWinnerUseCase,
                                    rejectWinnerUseCase: container.rejectWinnerUseCase,
                                    cancelBetUseCase: container.cancelBetUseCase
                                )
                            )
                        } label: {
                            HStack {
                                Spacer(minLength: 0)

                                BetCardView(bet: bet)
                                    .frame(maxWidth: Theme.Layout.cardMaxWidth)

                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, Theme.Layout.cardHorizontalMargin)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }

            if let msg = viewModel.errorMessage {
                VStack {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(Theme.Colors.error)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.black.opacity(0.55)))
                    Spacer()
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - TopBar

    private func topBar(topInset: CGFloat) -> some View {
        ZStack {
            // Fundo “glass/dark” consistente (sem ficar gigante)
            Rectangle()
                .fill(.ultraThinMaterial)

            Rectangle()
                .fill(Color.black.opacity(0.55))

            Rectangle()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)

            HStack {
                Button("Sair") {
                    try? container.authRepository.signOut()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)

                Spacer()

                Text("Apostas")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: barHeight)
        .padding(.top, topInset)
    }
}

