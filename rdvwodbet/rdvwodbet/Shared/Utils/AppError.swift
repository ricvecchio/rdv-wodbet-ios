import Foundation

enum AppError: Error, LocalizedError, Equatable {
    case invalidInput(String)
    case notAuthenticated
    case permissionDenied
    case dataNotFound
    case network(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidInput(let msg): return msg
        case .notAuthenticated: return "Você precisa estar logado."
        case .permissionDenied: return "Você não tem permissão para essa ação."
        case .dataNotFound: return "Dados não encontrados."
        case .network(let msg): return "Erro de rede: \(msg)"
        case .unknown: return "Ocorreu um erro inesperado."
        }
    }
}
