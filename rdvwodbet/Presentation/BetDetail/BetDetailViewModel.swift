import Foundation
import Combine

@MainActor
final class BetDetailViewModel: ObservableObject {
    @Published private(set) var bet: Bet
    @Published var errorMessage: String?
    @Published var isWorking: Bool = false
    @Published var athleteAResultInput: String
    @Published var athleteBResultInput: String
    @Published var selectedWinnerUserId: String?

    let currentUser: AppUser

    private let proposeWinnerUseCase: ProposeWinnerUseCase
    private let confirmWinnerUseCase: ConfirmWinnerUseCase
    private let rejectWinnerUseCase: RejectWinnerUseCase
    private let cancelBetUseCase: CancelBetUseCase
    private let updateBetResultUseCase: UpdateBetResultUseCase
    private let voteOnBetUseCase: VoteOnBetUseCase

    private var cancellables = Set<AnyCancellable>()

    init(
        bet: Bet,
        currentUser: AppUser,
        proposeWinnerUseCase: ProposeWinnerUseCase,
        confirmWinnerUseCase: ConfirmWinnerUseCase,
        rejectWinnerUseCase: RejectWinnerUseCase,
        cancelBetUseCase: CancelBetUseCase,
        updateBetResultUseCase: UpdateBetResultUseCase,
        voteOnBetUseCase: VoteOnBetUseCase
    ) {
        self.bet = bet
        self.currentUser = currentUser
        self.proposeWinnerUseCase = proposeWinnerUseCase
        self.confirmWinnerUseCase = confirmWinnerUseCase
        self.rejectWinnerUseCase = rejectWinnerUseCase
        self.cancelBetUseCase = cancelBetUseCase
        self.updateBetResultUseCase = updateBetResultUseCase
        self.voteOnBetUseCase = voteOnBetUseCase
        self.athleteAResultInput = bet.athleteAResult ?? ""
        self.athleteBResultInput = bet.athleteBResult ?? ""
        self.selectedWinnerUserId = bet.proposedWinnerUserId
    }

    var isAthlete: Bool {
        currentUser.id == bet.athleteAUserId || currentUser.id == bet.athleteBUserId
    }

    var canEditBetResult: Bool {
        let isCreator = currentUser.id == bet.createdByUserId
        let isParticipant = currentUser.id == bet.athleteAUserId || currentUser.id == bet.athleteBUserId
        let isEditableStatus = bet.status == .open || bet.status == .disputed
        return isEditableStatus && (isCreator || isParticipant)
    }

    var canSaveBetResult: Bool {
        let athleteAResult = athleteAResultInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let athleteBResult = athleteBResultInput.trimmingCharacters(in: .whitespacesAndNewlines)

        return canEditBetResult &&
            !athleteAResult.isEmpty &&
            !athleteBResult.isEmpty &&
            selectedWinnerUserId != nil
    }

    var canConfirmResult: Bool {
        guard isAthlete else { return false }
        guard bet.status == .open || bet.status == .disputed else { return false }
        return bet.proposedWinnerUserId != nil
    }

    var currentUserAlreadyConfirmed: Bool {
        if currentUser.id == bet.athleteAUserId {
            return bet.athleteAConfirmed
        }

        if currentUser.id == bet.athleteBUserId {
            return bet.athleteBConfirmed
        }

        return false
    }

    var currentUserVote: String? {
        bet.voteOfUser(currentUser.id)
    }

    func selectWinner(userId: String) {
        selectedWinnerUserId = userId
    }

    func vote(for votedAthleteUserId: String) {
        errorMessage = nil
        isWorking = true

        voteOnBetUseCase.execute(
            betId: bet.id,
            voterUserId: currentUser.id,
            votedAthleteUserId: votedAthleteUserId
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            self.isWorking = false

            if case .failure(let err) = completion {
                self.errorMessage = err.localizedDescription
            }
        } receiveValue: { [weak self] _ in
            guard let self else { return }

            var newVotes = self.bet.votesByUserId
            newVotes[self.currentUser.id] = votedAthleteUserId
            self.bet = self.bet.updating(votesByUserId: newVotes)
        }
        .store(in: &cancellables)
    }

    func saveBetResult() {
        let athleteAResult = athleteAResultInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let athleteBResult = athleteBResultInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard canEditBetResult else {
            errorMessage = "Você não tem permissão para atualizar o resultado desta aposta."
            return
        }

        guard !athleteAResult.isEmpty, !athleteBResult.isEmpty else {
            errorMessage = "Preencha o resultado dos dois atletas."
            return
        }

        guard let selectedWinnerUserId else {
            errorMessage = "Selecione o vencedor da aposta."
            return
        }

        errorMessage = nil
        isWorking = true

        updateBetResultUseCase.execute(
            betId: bet.id,
            requesterUserId: currentUser.id,
            athleteAResult: athleteAResult,
            athleteBResult: athleteBResult,
            winnerUserId: selectedWinnerUserId
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            self.isWorking = false

            if case .failure(let err) = completion {
                self.errorMessage = err.localizedDescription
            }
        } receiveValue: { [weak self] _ in
            guard let self else { return }

            self.bet = self.bet.updating(
                status: .finished,
                proposedWinnerUserId: selectedWinnerUserId,
                athleteAConfirmed: true,
                athleteBConfirmed: true,
                confirmedWinnerUserId: selectedWinnerUserId,
                athleteAResult: .some(athleteAResult),
                athleteBResult: .some(athleteBResult)
            )
        }
        .store(in: &cancellables)
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
            } receiveValue: { [weak self] _ in
                guard let self else { return }

                self.bet = self.bet.updating(
                    status: .open,
                    proposedWinnerUserId: userId,
                    athleteAConfirmed: false,
                    athleteBConfirmed: false,
                    confirmedWinnerUserId: .some(nil)
                )
                self.selectedWinnerUserId = userId
            }
            .store(in: &cancellables)
    }

    func confirm() {
        guard canConfirmResult else {
            errorMessage = "Selecione um vencedor antes de confirmar."
            return
        }

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
            } receiveValue: { [weak self] _ in
                guard let self else { return }

                var newAthleteAConfirmed = self.bet.athleteAConfirmed
                var newAthleteBConfirmed = self.bet.athleteBConfirmed

                if self.currentUser.id == self.bet.athleteAUserId {
                    newAthleteAConfirmed = true
                }

                if self.currentUser.id == self.bet.athleteBUserId {
                    newAthleteBConfirmed = true
                }

                let didFinish = newAthleteAConfirmed && newAthleteBConfirmed

                self.bet = self.bet.updating(
                    status: didFinish ? .finished : self.bet.status,
                    athleteAConfirmed: newAthleteAConfirmed,
                    athleteBConfirmed: newAthleteBConfirmed,
                    confirmedWinnerUserId: didFinish ? self.bet.proposedWinnerUserId : self.bet.confirmedWinnerUserId
                )
            }
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
            } receiveValue: { [weak self] _ in
                guard let self else { return }

                self.bet = self.bet.updating(
                    status: .disputed,
                    proposedWinnerUserId: .some(nil),
                    athleteAConfirmed: false,
                    athleteBConfirmed: false,
                    confirmedWinnerUserId: .some(nil)
                )
                self.selectedWinnerUserId = nil
            }
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
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                self.bet = self.bet.updating(status: .canceled)
            }
            .store(in: &cancellables)
    }
}
