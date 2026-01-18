import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var bets: [Bet] = []
    @Published var errorMessage: String?

    let currentUser: AppUser
    private let observeBetsUseCase: ObserveBetsUseCase
    private let betRepository: BetRepository

    private var cancellables = Set<AnyCancellable>()

    init(currentUser: AppUser,
         observeBetsUseCase: ObserveBetsUseCase,
         betRepository: BetRepository) {
        self.currentUser = currentUser
        self.observeBetsUseCase = observeBetsUseCase
        self.betRepository = betRepository

        bind()
    }

    private func bind() {
        observeBetsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] bets in
                // Ordena por mais recentes (boa prática para feed)
                self?.bets = bets.sorted(by: { $0.createdAt > $1.createdAt })
            }
            .store(in: &cancellables)
    }
}
