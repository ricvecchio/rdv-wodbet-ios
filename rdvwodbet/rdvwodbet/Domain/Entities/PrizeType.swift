import Foundation

enum PrizeType: String, CaseIterable, Codable {
    case water
    case gatorade
    case beer
    case shake
    case other

    var displayName: String {
        switch self {
        case .water: return "Água"
        case .gatorade: return "Gatorade"
        case .beer: return "Cerveja"
        case .shake: return "Shake"
        case .other: return "Outro"
        }
    }
}
