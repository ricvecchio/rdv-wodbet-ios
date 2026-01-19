import Foundation

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
    let proposedWinnerUserId: String?
    let athleteAConfirmed: Bool
    let athleteBConfirmed: Bool
    let confirmedWinnerUserId: String?

    init(id: String, data: [String: Any]) {
        self.id = id
        self.createdAt = (data["createdAt"] as? Date) ?? Date()
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
    }
}
