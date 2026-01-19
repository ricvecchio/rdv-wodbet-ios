import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    let container: AppDIContainer

    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            List {
                if let msg = viewModel.errorMessage {
                    Text(msg)
                        .foregroundStyle(.red)
                }

                if viewModel.bets.isEmpty {
                    VStack(spacing: 10) {
                        Text("Nenhuma aposta por aqui ainda.")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text("Crie a primeira aposta do WOD do dia 😄")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .listRowBackground(Color.clear)
                }

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
                    .listRowBackground(Color.clear) // 🔥 impede branco
                }
            }
            .scrollContentBackground(.hidden) // 🔥 remove o fundo padrão do List
            .listStyle(.plain)
            .navigationTitle("Apostas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreate = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                CreateBetView(
                    viewModel: CreateBetViewModel(
                        currentUser: viewModel.currentUser,
                        userRepository: container.userRepository,
                        createBetUseCase: container.createBetUseCase
                    )
                )
            }
        }
        // 🔥 garante que a NavigationStack não pinte por trás
        .tint(.white)
    }
}

