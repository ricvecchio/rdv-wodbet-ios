import Foundation
import FirebaseFirestore

struct BetDTO {
    let id: String
    let createdAt: Date
    let createdByUserId: String
    let athleteAUserId: String
    let athleteBUserId: String
    let wodTitle: String
    let prizeType: String
    let prizeOtherDescription: String?
    let status: String
    let expiresAt: Date
    let proposedWinnerUserId: String?
    let athleteAConfirmed: Bool
    let athleteBConfirmed: Bool
    let confirmedWinnerUserId: String?
    let votesByUserId: [String: String]

    init(id: String, data: [String: Any]) {
        self.id = id

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else if let date = data["createdAt"] as? Date {
            self.createdAt = date
        } else {
            self.createdAt = Date()
        }

        if let ts = data["expiresAt"] as? Timestamp {
            self.expiresAt = ts.dateValue()
        } else if let date = data["expiresAt"] as? Date {
            self.expiresAt = date
        } else {
            self.expiresAt = Date()
        }

        self.createdByUserId = data["createdByUserId"] as? String ?? ""
        self.athleteAUserId = data["athleteAUserId"] as? String ?? ""
        self.athleteBUserId = data["athleteBUserId"] as? String ?? ""
        self.wodTitle = data["wodTitle"] as? String ?? ""
        self.prizeType = data["prizeType"] as? String ?? PrizeType.water.rawValue
        self.prizeOtherDescription = data["prizeOtherDescription"] as? String
        self.status = data["status"] as? String ?? BetStatus.open.rawValue
        self.proposedWinnerUserId = data["proposedWinnerUserId"] as? String
        self.athleteAConfirmed = data["athleteAConfirmed"] as? Bool ?? false
        self.athleteBConfirmed = data["athleteBConfirmed"] as? Bool ?? false
        self.confirmedWinnerUserId = data["confirmedWinnerUserId"] as? String

        if let votes = data["votes"] as? [String: String] {
            self.votesByUserId = votes
        } else if let votes = data["votes"] as? [String: Any] {
            self.votesByUserId = votes.reduce(into: [:]) { partialResult, element in
                if let votedUserId = element.value as? String {
                    partialResult[element.key] = votedUserId
                }
            }
        } else {
            self.votesByUserId = [:]
        }
    }
}
