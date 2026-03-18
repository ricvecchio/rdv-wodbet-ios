import Foundation
import Combine

final class CreateBetUseCase {
    private let betRepository: BetRepository

    init(betRepository: BetRepository) {
        self.betRepository = betRepository
    }

    func execute(
        createdByUserId: String,
        athleteAUserId: String,
        athleteBUserId: String,
        wodTitle: String,
        prizeType: PrizeType,
        prizeOtherDescription: String?,
        expiresAt: Date
    ) -> AnyPublisher<Void, AppError> {

        do {
            try Validators.validateCreateBet(
                athleteA: athleteAUserId,
                athleteB: athleteBUserId,
                wodTitle: wodTitle,
                prizeType: prizeType,
                prizeOtherDescription: prizeOtherDescription
            )
        } catch let error as AppError {
            return Fail(error: error).eraseToAnyPublisher()
        } catch {
            return Fail(error: .unknown).eraseToAnyPublisher()
        }

        let calendar = Calendar.current
        let expirationAtEndOfDay = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: expiresAt
        ) ?? expiresAt

        let bet = Bet(
            id: UUID().uuidString,
            createdAt: Date(),
            createdByUserId: createdByUserId,
            athleteAUserId: athleteAUserId,
            athleteBUserId: athleteBUserId,
            wodTitle: wodTitle,
            prizeType: prizeType,
            prizeOtherDescription: prizeOtherDescription,
            status: .open,
            expiresAt: expirationAtEndOfDay,
            proposedWinnerUserId: nil,
            athleteAConfirmed: false,
            athleteBConfirmed: false,
            confirmedWinnerUserId: nil
        )

        return betRepository.createBet(bet)
    }
}
