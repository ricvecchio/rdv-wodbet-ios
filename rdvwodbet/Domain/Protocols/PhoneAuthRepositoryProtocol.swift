import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: Protocolo de autenticação via telefone (backend Java).
// Mantido separado de AuthRepository para não quebrar o fluxo Firebase existente.

/// Resultado do login com telefone.
enum PhoneLoginResult {
    /// Usuário com uuid já reconhecido — login direto.
    case loggedIn(AppUser)
    /// Telefone ou uuid desconhecido — backend enviou código de confirmação.
    case codeRequired
}

protocol PhoneAuthRepositoryProtocol {
    /// POST /users/login  → 200 (.loggedIn) | 202 (.codeRequired)
    func loginWithPhone(phone: String, uuid: String) -> AnyPublisher<PhoneLoginResult, AppError>

    /// POST /users/confirm  → 200 (AppUser) | 400/401 (invalidInput) | 404 (dataNotFound)
    func confirmPhone(phone: String, uuid: String, code: String) -> AnyPublisher<AppUser, AppError>

    /// PUT /users/{id}  → 200 (AppUser atualizado)
    func updateUserProfile(userId: String, name: String, description: String?) -> AnyPublisher<AppUser, AppError>
}

