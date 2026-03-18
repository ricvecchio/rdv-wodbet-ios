import Foundation
import Combine

final class VoteOnBetUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute(
        betId: String,
        voterUserId: String,
        votedAthleteUserId: String
    ) -> AnyPublisher<Void, AppError> {
        betRepository.voteOnBet(
            betId: betId,
            voterUserId: voterUserId,
            votedAthleteUserId: votedAthleteUserId
        )
    }
}
