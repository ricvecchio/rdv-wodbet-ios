import Foundation
import Combine

final class CancelBetUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute(betId: String, requesterUserId: String) -> AnyPublisher<Void, AppError> {
        betRepository.cancelBet(betId: betId, requesterUserId: requesterUserId)
    }
}
