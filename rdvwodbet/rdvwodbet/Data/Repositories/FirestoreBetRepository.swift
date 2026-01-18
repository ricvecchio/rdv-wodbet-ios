import Foundation
import Combine

final class FirestoreBetRepository: BetRepository {
    private let dataSource: FirestoreBetDataSource

    init(dataSource: FirestoreBetDataSource) {
        self.dataSource = dataSource
    }

    func observeBets() -> AnyPublisher<[Bet], AppError> {
        dataSource.observeBets()
            .map { $0.map(BetMapper.toDomain) }
            .eraseToAnyPublisher()
    }

    func createBet(_ bet: Bet) -> AnyPublisher<Void, AppError> {
        dataSource.createBet(betId: bet.id, data: BetMapper.toFirestore(bet))
    }

    func proposeWinner(betId: String, proposedWinnerUserId: String) -> AnyPublisher<Void, AppError> {
        // Ao propor, reseta confirmações (boa prática para evitar confirmação “antiga”)
        return dataSource.setBet(betId: betId, data: [
            "proposedWinnerUserId": proposedWinnerUserId,
            "athleteAConfirmed": false,
            "athleteBConfirmed": false,
            "status": BetStatus.open.rawValue,
            "confirmedWinnerUserId": NSNull()
        ])
    }

    func confirmWinner(betId: String, confirmerUserId: String) -> AnyPublisher<Void, AppError> {
        // Implementação completa requer ler a aposta para saber se confirmer é A ou B
        // No próximo passo fazemos isso com transação do Firestore (correto e consistente)
        return Fail(error: .invalidInput("confirmWinner ainda precisa da transação Firestore."))
            .eraseToAnyPublisher()
    }

    func rejectWinner(betId: String, rejectorUserId: String) -> AnyPublisher<Void, AppError> {
        // Idem: precisa transação
        return dataSource.setBet(betId: betId, data: [
            "status": BetStatus.disputed.rawValue
        ])
    }

    func cancelBet(betId: String, requesterUserId: String) -> AnyPublisher<Void, AppError> {
        return dataSource.setBet(betId: betId, data: [
            "status": BetStatus.canceled.rawValue
        ])
    }
}
