import Foundation

enum Validators {
    static func validateCreateBet(
        athleteA: String,
        athleteB: String,
        wodTitle: String,
        prizeType: PrizeType,
        prizeOtherDescription: String?
    ) throws {
        if athleteA == athleteB {
            throw AppError.invalidInput("Atleta A e Atleta B não podem ser a mesma pessoa.")
        }
        if wodTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw AppError.invalidInput("Informe o WOD do dia.")
        }
        if prizeType == .other {
            let text = (prizeOtherDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty {
                throw AppError.invalidInput("Descreva o prêmio quando selecionar 'Outro'.")
            }
        }
    }

    static func validateDisplayName(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count < 2 {
            throw AppError.invalidInput("Seu apelido deve ter pelo menos 2 caracteres.")
        }
    }
}
