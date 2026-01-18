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

    /// Vencedor proposto (alguém sugeriu A ou B)
    let proposedWinnerUserId: String?

    /// Confirmações por atleta (para fase 1: boolean simples)
    let athleteAConfirmed: Bool
    let athleteBConfirmed: Bool

    /// Quando finalizada, o vencedor confirmado
    let confirmedWinnerUserId: String?
}
