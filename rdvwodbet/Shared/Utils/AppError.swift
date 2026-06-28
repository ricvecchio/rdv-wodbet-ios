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
        case .notAuthenticated: return "Sessão inválida. Faça login novamente."
        case .permissionDenied: return "Você não possui permissão para essa ação."
        case .dataNotFound: return "Registro não encontrado."
        case .network(let msg): return msg
        case .unknown: return "Ocorreu um erro inesperado."
        }
    }
}
