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
        case athleteAUserId
        case athleteBUserId
        case wodTitle
        case prizeType
        case prizeOtherDescription
        case status
        case winnerUserId
        case proposedWinnerUserId
        case athleteAConfirmed
        case athleteBConfirmed
        case confirmedWinnerUserId
        case votesByUserId
        case votes
        case athleteAResult
        case athleteBResult
        case createdAt
        case expiresAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdByUserId = try container.decodeIfPresent(String.self, forKey: .createdByUserId) ?? ""
        athleteAUserId = try container.decodeIfPresent(String.self, forKey: .athleteAUserId) ?? ""
        athleteBUserId = try container.decodeIfPresent(String.self, forKey: .athleteBUserId) ?? ""
        wodTitle = try container.decodeIfPresent(String.self, forKey: .wodTitle) ?? ""
        prizeType = try container.decodeIfPresent(String.self, forKey: .prizeType) ?? PrizeType.water.rawValue
        prizeOtherDescription = try container.decodeIfPresent(String.self, forKey: .prizeOtherDescription)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? BetStatus.open.rawValue
        winnerUserId = try container.decodeIfPresent(String.self, forKey: .winnerUserId)
        proposedWinnerUserId = try container.decodeIfPresent(String.self, forKey: .proposedWinnerUserId)
        athleteAConfirmed = try container.decodeIfPresent(Bool.self, forKey: .athleteAConfirmed) ?? false
        athleteBConfirmed = try container.decodeIfPresent(Bool.self, forKey: .athleteBConfirmed) ?? false
        confirmedWinnerUserId = try container.decodeIfPresent(String.self, forKey: .confirmedWinnerUserId)
        athleteAResult = try container.decodeIfPresent(String.self, forKey: .athleteAResult)
        athleteBResult = try container.decodeIfPresent(String.self, forKey: .athleteBResult)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        expiresAt = try container.decodeIfPresent(String.self, forKey: .expiresAt)

        if let votes = try container.decodeIfPresent([String: String].self, forKey: .votesByUserId) {
            votesByUserId = votes
        } else if let votes = try container.decodeIfPresent([String: String].self, forKey: .votes) {
            votesByUserId = votes
        } else {
            votesByUserId = [:]
        }
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

