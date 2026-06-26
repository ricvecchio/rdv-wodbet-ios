import Foundation

enum BackendBetMapper {
    static func toDomain(_ dto: BetBackendDTO) -> Bet {
        let normalizedPrize = normalizeEnumValue(dto.prizeType)
        let normalizedStatus = normalizeEnumValue(dto.status)
        let prize = PrizeType(rawValue: normalizedPrize) ?? .water
        let baseStatus = BetStatus(rawValue: normalizedStatus) ?? .open
        let expiresAt = parseDate(dto.expiresAt)
        let resolvedStatus = resolveStatus(baseStatus: baseStatus, expiresAt: expiresAt)
        let fallbackAthleteA = dto.athleteAUserId.nonEmptyOrNil ?? "athlete_a"
        let fallbackAthleteB = dto.athleteBUserId.nonEmptyOrNil ?? "athlete_b"
        let createdBy = dto.createdByUserId.nonEmptyOrNil ?? fallbackAthleteA

        return Bet(
            id: dto.id.nonEmptyOrNil ?? UUID().uuidString,
            createdAt: parseDate(dto.createdAt),
            createdByUserId: createdBy,
            athleteAUserId: fallbackAthleteA,
            athleteBUserId: fallbackAthleteB,
            wodTitle: dto.wodTitle.nonEmptyOrNil ?? "Aposta",
            prizeType: prize,
            prizeOtherDescription: dto.prizeOtherDescription?.nonEmptyOrNil,
            status: resolvedStatus,
            expiresAt: expiresAt,
            proposedWinnerUserId: dto.proposedWinnerUserId?.nonEmptyOrNil ?? dto.winnerUserId?.nonEmptyOrNil ?? dto.confirmedWinnerUserId?.nonEmptyOrNil,
            athleteAConfirmed: dto.athleteAConfirmed,
            athleteBConfirmed: dto.athleteBConfirmed,
            confirmedWinnerUserId: dto.confirmedWinnerUserId?.nonEmptyOrNil ?? dto.winnerUserId?.nonEmptyOrNil,
            votesByUserId: sanitizeVotes(dto.votesByUserId),
            athleteAResult: dto.athleteAResult?.nonEmptyOrNil,
            athleteBResult: dto.athleteBResult?.nonEmptyOrNil
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

    private static func sanitizeVotes(_ rawVotes: [String: String]) -> [String: String] {
        rawVotes.reduce(into: [:]) { partialResult, pair in
            guard
                let userId = pair.key.nonEmptyOrNil,
                let votedUserId = pair.value.nonEmptyOrNil
            else {
                return
            }
            partialResult[userId] = votedUserId
        }
    }

    private static func normalizeEnumValue(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
    }

    private static func isoString(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

private extension String {
    var nonEmptyOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

