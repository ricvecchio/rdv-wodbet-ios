import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    @Published private(set) var bets: [Bet] = []
    @Published private(set) var usersById: [String: AppUser] = [:]
    @Published var errorMessage: String?

    let currentUser: AppUser
    private let observeBetsUseCase: ObserveBetsUseCase
    private let userRepository: UserRepository

    private var cancellables = Set<AnyCancellable>()

    init(
        currentUser: AppUser,
        observeBetsUseCase: ObserveBetsUseCase,
        userRepository: UserRepository
    ) {
        self.currentUser = currentUser
        self.observeBetsUseCase = observeBetsUseCase
        self.userRepository = userRepository

        bind()
    }

    private func bind() {
        let betsPublisher = observeBetsUseCase.execute()
        let usersPublisher = userRepository.observeAllUsers()

        betsPublisher
            .combineLatest(usersPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] bets, users in
                guard let self else { return }

                // ✅ usersById para resolver nomes no feed/detalhe
                self.usersById = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })

                // ✅ Ordena por mais recentes (boa prática para feed)
                self.bets = bets.sorted(by: { $0.createdAt > $1.createdAt })
            }
            .store(in: &cancellables)
    }

    func displayName(for userId: String) -> String {
        usersById[userId]?.displayName ?? "—"
    }
}

