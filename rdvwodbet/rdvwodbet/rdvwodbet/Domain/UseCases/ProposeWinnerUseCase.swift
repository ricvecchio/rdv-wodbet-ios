import Foundation
import Combine

final class ProposeWinnerUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute(betId: String, proposedWinnerUserId: String) -> AnyPublisher<Void, AppError> {
        betRepository.proposeWinner(betId: betId, proposedWinnerUserId: proposedWinnerUserId)
    }
}
