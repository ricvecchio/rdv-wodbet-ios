import Foundation
import Combine

final class BackendBetRepository: BetRepository {
    private let remoteDataSource: BackendBetRemoteDataSource

    init(remoteDataSource: BackendBetRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func observeBets() -> AnyPublisher<[Bet], AppError> {
        remoteDataSource.fetchBets()
            .map { dtos in
                dtos.map { BackendBetMapper.toDomain($0) }
            }
            .eraseToAnyPublisher()
    }

    func createBet(_ bet: Bet) -> AnyPublisher<Void, AppError> {
        remoteDataSource.createBet(bet)
    }

    func proposeWinner(betId: String, requesterUserId: String, proposedWinnerUserId: String) -> AnyPublisher<Void, AppError> {
        remoteDataSource.proposeWinner(
            betId: betId,
            requesterUserId: requesterUserId,
            proposedWinnerUserId: proposedWinnerUserId
        )
    }

    func confirmWinner(betId: String, confirmerUserId: String) -> AnyPublisher<Void, AppError> {
        remoteDataSource.confirmWinner(betId: betId, confirmerUserId: confirmerUserId)
    }

    func rejectWinner(betId: String, rejectorUserId: String) -> AnyPublisher<Void, AppError> {
        remoteDataSource.rejectWinner(betId: betId, rejectorUserId: rejectorUserId)
    }

    func cancelBet(betId: String, requesterUserId: String) -> AnyPublisher<Void, AppError> {
        remoteDataSource.cancelBet(betId: betId, requesterUserId: requesterUserId)
    }

    func updateBetResult(
        betId: String,
        requesterUserId: String,
        athleteAResult: String,
        athleteBResult: String,
        winnerUserId: String
    ) -> AnyPublisher<Void, AppError> {
        remoteDataSource.updateBetResult(
            betId: betId,
            requesterUserId: requesterUserId,
            athleteAResult: athleteAResult,
            athleteBResult: athleteBResult,
            winnerUserId: winnerUserId
        )
    }

    func voteOnBet(betId: String, voterUserId: String, votedAthleteUserId: String) -> AnyPublisher<Void, AppError> {
        remoteDataSource.voteOnBet(
            betId: betId,
            voterUserId: voterUserId,
            votedAthleteUserId: votedAthleteUserId
        )
    }
}

