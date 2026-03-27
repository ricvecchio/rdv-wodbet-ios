import Foundation
import Combine

final class UpdateBetResultUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute(
        betId: String,
        requesterUserId: String,
        athleteAResult: String,
        athleteBResult: String,
        winnerUserId: String
    ) -> AnyPublisher<Void, AppError> {
        betRepository.updateBetResult(
            betId: betId,
            requesterUserId: requesterUserId,
            athleteAResult: athleteAResult,
            athleteBResult: athleteBResult,
            winnerUserId: winnerUserId
        )
    }
}
