import Foundation

enum BetStatus: String, Codable {
    case open
    case finished
    case canceled
    case disputed

    var label: String {
        switch self {
        case .open: return "⏳ Aberta"
        case .finished: return "🏆 Finalizada"
        case .canceled: return "❌ Cancelada"
        case .disputed: return "⚔️ Disputa"
        }
    }
}
