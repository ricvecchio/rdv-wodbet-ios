import Foundation
import Combine

final class ConfirmWinnerUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute(betId: String, confirmerUserId: String) -> AnyPublisher<Void, AppError> {
        betRepository.confirmWinner(betId: betId, confirmerUserId: confirmerUserId)
    }
}
