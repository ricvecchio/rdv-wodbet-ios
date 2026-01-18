import Foundation
import Combine

final class ObserveBetsUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute() -> AnyPublisher<[Bet], AppError> {
        betRepository.observeBets()
    }
}
