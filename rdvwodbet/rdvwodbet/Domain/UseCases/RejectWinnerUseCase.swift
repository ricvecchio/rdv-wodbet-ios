import Foundation
import Combine

final class RejectWinnerUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute(betId: String, rejectorUserId: String) -> AnyPublisher<Void, AppError> {
        betRepository.rejectWinner(betId: betId, rejectorUserId: rejectorUserId)
    }
}
