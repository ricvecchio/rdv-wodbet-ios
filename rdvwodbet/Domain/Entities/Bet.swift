import Foundation

struct Bet: Identifiable, Equatable {
    let id: String
    let createdAt: Date
    let createdByUserId: String
    let athleteAUserId: String
    let athleteBUserId: String
    let wodTitle: String
    let prizeType: PrizeType
    let prizeOtherDescription: String?
    let status: BetStatus
    let expiresAt: Date
    let proposedWinnerUserId: String?
    let athleteAConfirmed: Bool
    let athleteBConfirmed: Bool
    let confirmedWinnerUserId: String?
}
