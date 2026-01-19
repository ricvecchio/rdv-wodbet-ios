import Foundation
import Combine

protocol BetRepository {
    func observeBets() -> AnyPublisher<[Bet], AppError>
    func createBet(_ bet: Bet) -> AnyPublisher<Void, AppError>

    func proposeWinner(betId: String, proposedWinnerUserId: String) -> AnyPublisher<Void, AppError>
    func confirmWinner(betId: String, confirmerUserId: String) -> AnyPublisher<Void, AppError>
    func rejectWinner(betId: String, rejectorUserId: String) -> AnyPublisher<Void, AppError>

    func cancelBet(betId: String, requesterUserId: String) -> AnyPublisher<Void, AppError>
}
