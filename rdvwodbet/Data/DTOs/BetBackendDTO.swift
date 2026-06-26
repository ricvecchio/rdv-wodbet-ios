import Foundation
import Combine
// ...existing code...

struct BetBackendDTO: Decodable {
    let id: String
    let createdByUserId: String
    let athleteAUserId: String
    let athleteBUserId: String
    let wodTitle: String
    let prizeType: String
    let prizeOtherDescription: String?
    let status: String
    let winnerUserId: String?
    let proposedWinnerUserId: String?
    let athleteAConfirmed: Bool
    let athleteBConfirmed: Bool
    let confirmedWinnerUserId: String?
    let votesByUserId: [String: String]
    let athleteAResult: String?
    let athleteBResult: String?
    let createdAt: String?
    let expiresAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case createdByUserId
        case created_by_user_id = "created_by_user_id"
        case createdBy
        case athleteAUserId
        case athlete_a_user_id = "athlete_a_user_id"
        case athleteBUserId
        case athlete_b_user_id = "athlete_b_user_id"
        case athleteA
        case athleteB
        case wodTitle
        case wod_title = "wod_title"
        case prizeType
        case prize_type = "prize_type"
        case prizeOtherDescription
        case prize_other_description = "prize_other_description"
        case status
        case winnerUserId
        case winner_user_id = "winner_user_id"
        case winner
        case proposedWinnerUserId
        case proposed_winner_user_id = "proposed_winner_user_id"
        case proposedWinner
        case athleteAConfirmed
        case athlete_a_confirmed = "athlete_a_confirmed"
        case athleteBConfirmed
        case athlete_b_confirmed = "athlete_b_confirmed"
        case confirmedWinnerUserId
        case confirmed_winner_user_id = "confirmed_winner_user_id"
        case confirmedWinner
        case votesByUserId
        case votes_by_user_id = "votes_by_user_id"
        case votes
        case athleteAResult
        case athlete_a_result = "athlete_a_result"
        case athleteBResult
        case athlete_b_result = "athlete_b_result"
        case createdAt
        case created_at = "created_at"
        case expiresAt
        case expires_at = "expires_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let athleteARef = try container.decodeIfPresent(BetUserReferenceDTO.self, forKey: .athleteA)
        let athleteBRef = try container.decodeIfPresent(BetUserReferenceDTO.self, forKey: .athleteB)
        let createdByRef = try container.decodeIfPresent(BetUserReferenceDTO.self, forKey: .createdBy)
        let winnerRef = try container.decodeIfPresent(BetUserReferenceDTO.self, forKey: .winner)
        let proposedWinnerRef = try container.decodeIfPresent(BetUserReferenceDTO.self, forKey: .proposedWinner)
        let confirmedWinnerRef = try container.decodeIfPresent(BetUserReferenceDTO.self, forKey: .confirmedWinner)

        id = (try? decodeStringFromStringOrNumber(container, forKey: .id)) ?? UUID().uuidString
        createdByUserId =
            (try decodeOptionalStringFromStringOrNumber(container, forKey: .createdByUserId))
            ?? (try decodeOptionalStringFromStringOrNumber(container, forKey: .created_by_user_id))
            ?? createdByRef?.resolvedUserId
            ?? ""
        athleteAUserId =
            (try decodeOptionalStringFromStringOrNumber(container, forKey: .athleteAUserId))
            ?? (try decodeOptionalStringFromStringOrNumber(container, forKey: .athlete_a_user_id))
            ?? athleteARef?.resolvedUserId
            ?? ""
        athleteBUserId =
            (try decodeOptionalStringFromStringOrNumber(container, forKey: .athleteBUserId))
            ?? (try decodeOptionalStringFromStringOrNumber(container, forKey: .athlete_b_user_id))
            ?? athleteBRef?.resolvedUserId
            ?? ""

        wodTitle =
            (try container.decodeIfPresent(String.self, forKey: .wodTitle))?.trimmedNonEmpty
            ?? (try container.decodeIfPresent(String.self, forKey: .wod_title))?.trimmedNonEmpty
            ?? ""
        prizeType =
            (try container.decodeIfPresent(String.self, forKey: .prizeType))?.trimmedNonEmpty
            ?? (try container.decodeIfPresent(String.self, forKey: .prize_type))?.trimmedNonEmpty
            ?? PrizeType.water.rawValue
        prizeOtherDescription =
            (try container.decodeIfPresent(String.self, forKey: .prizeOtherDescription))?.trimmedNonEmpty
            ?? (try container.decodeIfPresent(String.self, forKey: .prize_other_description))?.trimmedNonEmpty
        status = (try container.decodeIfPresent(String.self, forKey: .status))?.trimmedNonEmpty ?? BetStatus.open.rawValue

        winnerUserId =
            (try decodeOptionalStringFromStringOrNumber(container, forKey: .winnerUserId))
            ?? (try decodeOptionalStringFromStringOrNumber(container, forKey: .winner_user_id))
            ?? winnerRef?.resolvedUserId
        proposedWinnerUserId =
            (try decodeOptionalStringFromStringOrNumber(container, forKey: .proposedWinnerUserId))
            ?? (try decodeOptionalStringFromStringOrNumber(container, forKey: .proposed_winner_user_id))
            ?? proposedWinnerRef?.resolvedUserId
        confirmedWinnerUserId =
            (try decodeOptionalStringFromStringOrNumber(container, forKey: .confirmedWinnerUserId))
            ?? (try decodeOptionalStringFromStringOrNumber(container, forKey: .confirmed_winner_user_id))
            ?? confirmedWinnerRef?.resolvedUserId

        athleteAConfirmed =
            decodeOptionalBool(container, forKey: .athleteAConfirmed)
            ?? decodeOptionalBool(container, forKey: .athlete_a_confirmed)
            ?? false
        athleteBConfirmed =
            decodeOptionalBool(container, forKey: .athleteBConfirmed)
            ?? decodeOptionalBool(container, forKey: .athlete_b_confirmed)
            ?? false

        athleteAResult =
            (try container.decodeIfPresent(String.self, forKey: .athleteAResult))?.trimmedNonEmpty
            ?? (try container.decodeIfPresent(String.self, forKey: .athlete_a_result))?.trimmedNonEmpty
        athleteBResult =
            (try container.decodeIfPresent(String.self, forKey: .athleteBResult))?.trimmedNonEmpty
            ?? (try container.decodeIfPresent(String.self, forKey: .athlete_b_result))?.trimmedNonEmpty
        createdAt =
            (try container.decodeIfPresent(String.self, forKey: .createdAt))?.trimmedNonEmpty
            ?? (try container.decodeIfPresent(String.self, forKey: .created_at))?.trimmedNonEmpty
        expiresAt =
            (try container.decodeIfPresent(String.self, forKey: .expiresAt))?.trimmedNonEmpty
            ?? (try container.decodeIfPresent(String.self, forKey: .expires_at))?.trimmedNonEmpty

        votesByUserId = decodeVotesByUserId(from: container)
    }

    private func decodeStringFromStringOrNumber(
        _ container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> String {
        guard let value = try decodeOptionalStringFromStringOrNumber(container, forKey: key) else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "Campo ausente: \(key.stringValue)")
            )
        }
        return value
    }

    private func decodeOptionalStringFromStringOrNumber(
        _ container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) throws -> String? {
        if let value = try container.decodeIfPresent(String.self, forKey: key)?.trimmedNonEmpty {
            return value
        }
        if let value = try? container.decodeIfPresent(Int64.self, forKey: key) {
            return value.map(String.init)
        }
        if let value = try? container.decodeIfPresent(Double.self, forKey: key), let raw = value {
            return raw.truncatingRemainder(dividingBy: 1) == 0 ? String(Int64(raw)) : String(raw)
        }
        return nil
    }

    private func decodeOptionalBool(
        _ container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Bool? {
        if let bool = try? container.decodeIfPresent(Bool.self, forKey: key) {
            return bool
        }
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key), let intValue {
            return intValue != 0
        }
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key),
           let stringValue {
            switch stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "true", "1", "yes", "y": return true
            case "false", "0", "no", "n": return false
            default: return nil
            }
        }
        return nil
    }

    private func decodeVotesByUserId(from container: KeyedDecodingContainer<CodingKeys>) -> [String: String] {
        if let votes = decodeVotes(for: .votesByUserId, from: container) {
            return votes
        }
        if let votes = decodeVotes(for: .votes_by_user_id, from: container) {
            return votes
        }
        if let votes = decodeVotes(for: .votes, from: container) {
            return votes
        }
        return [:]
    }

    private func decodeVotes(
        for key: CodingKeys,
        from container: KeyedDecodingContainer<CodingKeys>
    ) -> [String: String]? {
        if let values = try? container.decodeIfPresent([String: String].self, forKey: key), let values {
            return values
        }
        if let values = try? container.decodeIfPresent([String: Int64].self, forKey: key), let values {
            return values.mapValues(String.init)
        }
        if let values = try? container.decodeIfPresent([String: Double].self, forKey: key), let values {
            return values.mapValues { value in
                value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int64(value)) : String(value)
            }
        }
        if let values = try? container.decodeIfPresent([String: StringOrNumberValue].self, forKey: key), let values {
            return values.mapValues(\.value)
        }
        return nil
    }
}

private struct BetUserReferenceDTO: Decodable {
    let id: String?
    let userId: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case user_id = "user_id"
    }

    var resolvedUserId: String? {
        userId ?? id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = Self.decodeOptionalStringFromStringOrNumber(container, forKey: .id)
        userId =
            Self.decodeOptionalStringFromStringOrNumber(container, forKey: .userId)
            ?? Self.decodeOptionalStringFromStringOrNumber(container, forKey: .user_id)
    }

    private static func decodeOptionalStringFromStringOrNumber(
        _ container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> String? {
        if let value = try? container.decodeIfPresent(String.self, forKey: key)?.trimmedNonEmpty {
            return value
        }
        if let value = try? container.decodeIfPresent(Int64.self, forKey: key) {
            return value.map(String.init)
        }
        if let value = try? container.decodeIfPresent(Double.self, forKey: key), let raw = value {
            return raw.truncatingRemainder(dividingBy: 1) == 0 ? String(Int64(raw)) : String(raw)
        }
        return nil
    }
}

private struct StringOrNumberValue: Decodable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self.value = value
            return
        }
        if let value = try? container.decode(Int64.self) {
            self.value = String(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self.value = value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int64(value)) : String(value)
            return
        }
        if let value = try? container.decode(Bool.self) {
            self.value = value ? "true" : "false"
            return
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Valor não suportado")
    }
}

private extension String {
    var trimmedNonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct BackendCreateBetRequestDTO: Encodable {
    let createdByUserId: String
    let athleteAUserId: String
    let athleteBUserId: String
    let wodTitle: String
    let prizeType: String
    let prizeOtherDescription: String?
    let expiresAt: String
}

struct BackendVoteOnBetRequestDTO: Encodable {
    let voterUserId: String
    let votedAthleteUserId: String
}

struct BackendProposeWinnerRequestDTO: Encodable {
    let requesterUserId: String
    let proposedWinnerUserId: String
}

struct BackendConfirmWinnerRequestDTO: Encodable {
    let confirmerUserId: String
}

struct BackendRejectWinnerRequestDTO: Encodable {
    let rejectorUserId: String
}

struct BackendCancelBetRequestDTO: Encodable {
    let requesterUserId: String
}

struct BackendUpdateBetResultRequestDTO: Encodable {
    let requesterUserId: String
    let athleteAResult: String
    let athleteBResult: String
    let winnerUserId: String
}

