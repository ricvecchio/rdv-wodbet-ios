import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    let container: AppDIContainer

    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 14) {
                            headerCard()

                            if viewModel.bets.isEmpty {
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
                            } else {
                                ForEach(viewModel.bets) { bet in
                                    let aName = viewModel.displayName(for: bet.athleteAUserId)
                                    let bName = viewModel.displayName(for: bet.athleteBUserId)

                                    NavigationLink {
                                        BetDetailView(
                                            viewModel: BetDetailViewModel(
                                                bet: bet,
                                                currentUser: viewModel.currentUser,
                                                proposeWinnerUseCase: container.proposeWinnerUseCase,
                                                confirmWinnerUseCase: container.confirmWinnerUseCase,
                                                rejectWinnerUseCase: container.rejectWinnerUseCase,
                                                cancelBetUseCase: container.cancelBetUseCase
                                            ),
                                            athleteAName: aName,
                                            athleteBName: bName
                                        )
                                    } label: {
                                        BetCardView(
                                            bet: bet,
                                            athleteAName: aName,
                                            athleteBName: bName
                                        )
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: Theme.Layout.cardMaxWidth)
                        .padding(.top, Theme.Layout.screenContentTopPadding)
                        .padding(.bottom, 28)
                        .frame(maxWidth: .infinity, alignment: .center)
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
        .tint(Theme.Colors.textPrimary)
    }

    @ViewBuilder
    private func headerCard() -> some View {
        GlassCard {
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("Apostas")
                        .font(.title3.bold())
                        .foregroundColor(Theme.Colors.textPrimary)

                    Text("Logado como \(viewModel.currentUser.displayName)")
                        .font(.footnote)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 10) {
                    Button {
                        try? container.authRepository.signOut()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Deslogar")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.22))
                        .cornerRadius(12)
                    }

                    Button {
                        showCreate = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Nova aposta")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.22))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}
