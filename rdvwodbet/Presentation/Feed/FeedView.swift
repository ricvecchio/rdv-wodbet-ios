import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    let container: AppDIContainer

    @State private var showCreate = false

    private let feedCardMaxWidth: CGFloat = 340

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        headerSection()

                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 14) {
                                if viewModel.bets.isEmpty {
                                    GlassCard {
                                        Text("Nenhuma aposta por aqui ainda.")
                                            .font(.headline)
                                            .foregroundColor(Theme.Colors.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: .infinity)

                                        Text("Crie a primeira aposta do WOD do dia ")
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
                                    .frame(maxWidth: feedCardMaxWidth)
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
                                                    cancelBetUseCase: container.cancelBetUseCase,
                                                    voteOnBetUseCase: container.voteOnBetUseCase
                                                ),
                                                athleteAName: aName,
                                                athleteBName: bName,
                                                usersById: viewModel.usersById
                                            )
                                        } label: {
                                            BetCardView(
                                                bet: bet,
                                                athleteAName: aName,
                                                athleteBName: bName,
                                                currentUserId: viewModel.currentUser.id,
                                                onVote: { athleteId in
                                                    viewModel.vote(
                                                        betId: bet.id,
                                                        athleteId: athleteId,
                                                        container: container
                                                    )
                                                }
                                            )
                                            .frame(maxWidth: feedCardMaxWidth)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .clipped()
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
            .safeAreaInset(edge: .bottom, spacing: 0) {
                footerSection()
                    .background(Color.black.opacity(0.65))
            }
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
    private func headerSection() -> some View {
        VStack(spacing: 4) {
            Text("Apostas")
                .font(.headline.bold())
                .foregroundColor(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Logado como \(viewModel.currentUser.displayName)")
                .font(.caption)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .padding(.horizontal, 16)
        .background(Color.black.opacity(0.65))
    }

    @ViewBuilder
    private func footerSection() -> some View {
        HStack(spacing: 10) {
            footerButton(
                title: "Deslogar",
                systemImage: "rectangle.portrait.and.arrow.right"
            ) {
                try? container.authRepository.signOut()
            }

            footerButton(
                title: "Nova aposta",
                systemImage: "plus.circle.fill"
            ) {
                showCreate = true
            }
        }
        .frame(maxWidth: Theme.Layout.cardMaxWidth)
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func footerButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundColor(Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(Color.black.opacity(0.55))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
