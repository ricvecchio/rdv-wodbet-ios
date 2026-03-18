import Foundation

enum BetMapper {

    static func toDomain(_ dto: BetDTO) -> Bet {
        let prize = PrizeType(rawValue: dto.prizeType) ?? .water
        let baseStatus = BetStatus(rawValue: dto.status) ?? .open

        let calendar = Calendar.current
        let now = Date()
        let isExpiredByDay = calendar.startOfDay(for: dto.expiresAt) < calendar.startOfDay(for: now)

        let resolvedStatus: BetStatus
        if (baseStatus == .open || baseStatus == .disputed) && isExpiredByDay {
            resolvedStatus = .expired
        } else {
            resolvedStatus = baseStatus
        }

        return Bet(
            id: dto.id,
            createdAt: dto.createdAt,
            createdByUserId: dto.createdByUserId,
            athleteAUserId: dto.athleteAUserId,
            athleteBUserId: dto.athleteBUserId,
            wodTitle: dto.wodTitle,
            prizeType: prize,
            prizeOtherDescription: dto.prizeOtherDescription,
            status: resolvedStatus,
            expiresAt: dto.expiresAt,
            proposedWinnerUserId: dto.proposedWinnerUserId,
            athleteAConfirmed: dto.athleteAConfirmed,
            athleteBConfirmed: dto.athleteBConfirmed,
            confirmedWinnerUserId: dto.confirmedWinnerUserId,
            votesByUserId: dto.votesByUserId
        )
    }

    static func toFirestore(_ bet: Bet) -> [String: Any] {
        var data: [String: Any] = [
            "createdAt": bet.createdAt,
            "createdByUserId": bet.createdByUserId,
            "athleteAUserId": bet.athleteAUserId,
            "athleteBUserId": bet.athleteBUserId,
            "wodTitle": bet.wodTitle,
            "prizeType": bet.prizeType.rawValue,
            "status": bet.status.rawValue,
            "expiresAt": bet.expiresAt,
            "athleteAConfirmed": bet.athleteAConfirmed,
            "athleteBConfirmed": bet.athleteBConfirmed,
            "votes": bet.votesByUserId
        ]

        data["prizeOtherDescription"] = bet.prizeOtherDescription as Any
        data["proposedWinnerUserId"] = bet.proposedWinnerUserId as Any
        data["confirmedWinnerUserId"] = bet.confirmedWinnerUserId as Any

        return data
    }
}
