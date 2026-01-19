import Foundation
import Combine

final class FirestoreBetRepository: BetRepository {
    private let dataSource: FirestoreBetDataSource

    init(dataSource: FirestoreBetDataSource) {
        self.dataSource = dataSource
    }

    func observeBets() -> AnyPublisher<[Bet], AppError> {
        dataSource.observeBets()
            .map { dtos in
                dtos.map { BetMapper.toDomain($0) }
            }
            .eraseToAnyPublisher()
    }

    func createBet(_ bet: Bet) -> AnyPublisher<Void, AppError> {
        dataSource.createBet(betId: bet.id, data: BetMapper.toFirestore(bet))
    }

    func proposeWinner(betId: String, proposedWinnerUserId: String) -> AnyPublisher<Void, AppError> {
        dataSource.setBet(betId: betId, data: [
            "proposedWinnerUserId": proposedWinnerUserId,
            "athleteAConfirmed": false,
            "athleteBConfirmed": false,
            "status": BetStatus.open.rawValue,
            "confirmedWinnerUserId": NSNull()
        ])
    }

    func confirmWinner(betId: String, confirmerUserId: String) -> AnyPublisher<Void, AppError> {
        // Ainda pendente: implementar transação Firestore
        return Fail(error: .invalidInput("confirmWinner ainda não implementado (falta transação Firestore)."))
            .eraseToAnyPublisher()
    }

    func rejectWinner(betId: String, rejectorUserId: String) -> AnyPublisher<Void, AppError> {
        dataSource.setBet(betId: betId, data: [
            "status": BetStatus.disputed.rawValue
        ])
    }

    func cancelBet(betId: String, requesterUserId: String) -> AnyPublisher<Void, AppError> {
        dataSource.setBet(betId: betId, data: [
            "status": BetStatus.canceled.rawValue
        ])
    }
}

