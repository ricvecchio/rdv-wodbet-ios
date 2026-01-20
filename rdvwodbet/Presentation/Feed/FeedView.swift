import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    let container: AppDIContainer

    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ZStack {
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

                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
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
                                        BetCardView(bet: bet)
                                    }
                                }
                            }
                            .frame(maxWidth: Theme.Layout.cardMaxWidth)
                            .padding(.top, 16)
                            .padding(.bottom, 28)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
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
                .navigationTitle("Apostas")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Sair") { try? container.authRepository.signOut() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showCreate = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
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
        .tint(.white)
    }
}
