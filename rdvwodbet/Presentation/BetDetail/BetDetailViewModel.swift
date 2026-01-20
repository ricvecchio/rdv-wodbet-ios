import Foundation
import Combine

@MainActor
final class BetDetailViewModel: ObservableObject {
    @Published private(set) var bet: Bet
    @Published var errorMessage: String?
    @Published var isWorking: Bool = false

    let currentUser: AppUser

    private let proposeWinnerUseCase: ProposeWinnerUseCase
    private let confirmWinnerUseCase: ConfirmWinnerUseCase
    private let rejectWinnerUseCase: RejectWinnerUseCase
    private let cancelBetUseCase: CancelBetUseCase

    private var cancellables = Set<AnyCancellable>()

    init(
        bet: Bet,
        currentUser: AppUser,
        proposeWinnerUseCase: ProposeWinnerUseCase,
        confirmWinnerUseCase: ConfirmWinnerUseCase,
        rejectWinnerUseCase: RejectWinnerUseCase,
        cancelBetUseCase: CancelBetUseCase
    ) {
        self.bet = bet
        self.currentUser = currentUser
        self.proposeWinnerUseCase = proposeWinnerUseCase
        self.confirmWinnerUseCase = confirmWinnerUseCase
        self.rejectWinnerUseCase = rejectWinnerUseCase
        self.cancelBetUseCase = cancelBetUseCase
    }

    var isAthlete: Bool {
        currentUser.id == bet.athleteAUserId || currentUser.id == bet.athleteBUserId
    }

    func proposeWinner(userId: String) {
        errorMessage = nil
        isWorking = true

        proposeWinnerUseCase.execute(betId: bet.id, proposedWinnerUserId: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isWorking = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func confirm() {
        errorMessage = nil
        isWorking = true

        confirmWinnerUseCase.execute(betId: bet.id, confirmerUserId: currentUser.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isWorking = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func reject() {
        errorMessage = nil
        isWorking = true

        rejectWinnerUseCase.execute(betId: bet.id, rejectorUserId: currentUser.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isWorking = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func cancel() {
        errorMessage = nil
        isWorking = true

        cancelBetUseCase.execute(betId: bet.id, requesterUserId: currentUser.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isWorking = false
                if case .failure(let err) = completion {
                    self.errorMessage = err.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

