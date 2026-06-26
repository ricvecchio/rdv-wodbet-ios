import Foundation

enum BackendBetMapper {
    static func toDomain(_ dto: BetBackendDTO) -> Bet {
        let prize = PrizeType(rawValue: dto.prizeType) ?? .water
        let baseStatus = BetStatus(rawValue: dto.status) ?? .open
        let resolvedStatus = resolveStatus(baseStatus: baseStatus, expiresAt: parseDate(dto.expiresAt))

        return Bet(
            id: dto.id,
            createdAt: parseDate(dto.createdAt),
            createdByUserId: dto.createdByUserId,
            athleteAUserId: dto.athleteAUserId,
            athleteBUserId: dto.athleteBUserId,
            wodTitle: dto.wodTitle,
            prizeType: prize,
            prizeOtherDescription: dto.prizeOtherDescription,
            status: resolvedStatus,
            expiresAt: parseDate(dto.expiresAt),
            proposedWinnerUserId: dto.proposedWinnerUserId ?? dto.winnerUserId ?? dto.confirmedWinnerUserId,
            athleteAConfirmed: dto.athleteAConfirmed,
            athleteBConfirmed: dto.athleteBConfirmed,
            confirmedWinnerUserId: dto.confirmedWinnerUserId ?? dto.winnerUserId,
            votesByUserId: dto.votesByUserId,
            athleteAResult: dto.athleteAResult,
            athleteBResult: dto.athleteBResult
        )
    }

    static func toCreateRequest(_ bet: Bet) -> BackendCreateBetRequestDTO {
        BackendCreateBetRequestDTO(
            createdByUserId: bet.createdByUserId,
            athleteAUserId: bet.athleteAUserId,
            athleteBUserId: bet.athleteBUserId,
            wodTitle: bet.wodTitle,
            prizeType: bet.prizeType.rawValue,
            prizeOtherDescription: bet.prizeOtherDescription,
            expiresAt: Self.isoString(from: bet.expiresAt)
        )
    }

    private static func resolveStatus(baseStatus: BetStatus, expiresAt: Date) -> BetStatus {
        let calendar = Calendar.current
        let now = Date()
        let isExpiredByDay = calendar.startOfDay(for: expiresAt) < calendar.startOfDay(for: now)

        if (baseStatus == .open || baseStatus == .disputed) && isExpiredByDay {
            return .expired
        }
        return baseStatus
    }

    private static func parseDate(_ raw: String?) -> Date {
        guard let raw else { return Date() }

        let formatters: [ISO8601DateFormatter] = [
            {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter
            }(),
            ISO8601DateFormatter()
        ]

        for formatter in formatters {
            if let date = formatter.date(from: raw) {
                return date
            }
        }

        if let timestamp = TimeInterval(raw) {
            return Date(timeIntervalSince1970: timestamp)
        }

        return Date()
    }

    private static func isoString(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

