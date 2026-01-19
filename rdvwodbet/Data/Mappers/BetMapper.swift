import Foundation

enum BetMapper {

    static func toDomain(_ dto: BetDTO) -> Bet {
        let prize = PrizeType(rawValue: dto.prizeType) ?? .water
        let status = BetStatus(rawValue: dto.status) ?? .open

        return Bet(
            id: dto.id,
            createdAt: dto.createdAt,
            createdByUserId: dto.createdByUserId,
            athleteAUserId: dto.athleteAUserId,
            athleteBUserId: dto.athleteBUserId,
            wodTitle: dto.wodTitle,
            prizeType: prize,
            prizeOtherDescription: dto.prizeOtherDescription,
            status: status,
            proposedWinnerUserId: dto.proposedWinnerUserId,
            athleteAConfirmed: dto.athleteAConfirmed,
            athleteBConfirmed: dto.athleteBConfirmed,
            confirmedWinnerUserId: dto.confirmedWinnerUserId
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
            "athleteAConfirmed": bet.athleteAConfirmed,
            "athleteBConfirmed": bet.athleteBConfirmed
        ]

        data["prizeOtherDescription"] = bet.prizeOtherDescription as Any
        data["proposedWinnerUserId"] = bet.proposedWinnerUserId as Any
        data["confirmedWinnerUserId"] = bet.confirmedWinnerUserId as Any

        return data
    }
}

