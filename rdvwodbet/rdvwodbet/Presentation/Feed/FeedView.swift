import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: FeedViewModel
    let container: AppDIContainer

    @State private var showCreate = false

    var body: some View {
        NavigationStack {
            List {
                if let msg = viewModel.errorMessage {
                    Text(msg).foregroundStyle(.red)
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
                }
            }
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
    }
}
