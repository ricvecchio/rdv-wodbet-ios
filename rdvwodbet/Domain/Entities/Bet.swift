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
    let votesByUserId: [String: String]

    var totalVotes: Int {
        votesByUserId.count
    }

    func voteCount(for athleteUserId: String) -> Int {
        votesByUserId.values.filter { $0 == athleteUserId }.count
    }

    func votePercentage(for athleteUserId: String) -> Int {
        let total = totalVotes
        guard total > 0 else { return 0 }
        let count = voteCount(for: athleteUserId)
        return Int((Double(count) / Double(total) * 100).rounded())
    }

    func voteOfUser(_ userId: String) -> String? {
        votesByUserId[userId]
    }
}
