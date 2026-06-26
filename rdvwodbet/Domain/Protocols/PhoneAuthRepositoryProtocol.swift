import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: Protocolo de autenticação via telefone (backend Java).
// Mantido separado de AuthRepository para não quebrar o fluxo Firebase existente.

/// Resultado do login com telefone.
enum PhoneLoginResult {
    /// Usuário com uuid já reconhecido — login direto.
    case loggedIn(AuthSession)
    /// Telefone ou uuid desconhecido — backend enviou código de confirmação.
    case codeRequired
}

/// Dados necessários para manter sessão autenticada no app.
struct AuthSession: Equatable {
    let jwt: String?
    let user: AppUser
    let phone: String
    let uuid: String
}

protocol PhoneAuthRepositoryProtocol {
    /// POST /users/login  → 200 (.loggedIn) | 202 (.codeRequired)
    func loginWithPhone(phone: String, uuid: String) -> AnyPublisher<PhoneLoginResult, AppError>

    /// POST /users/confirm  → 200 (AuthSession) | 400/401 (invalidInput) | 404 (dataNotFound)
    func confirmPhone(phone: String, uuid: String, code: String) -> AnyPublisher<AuthSession, AppError>

    /// PUT /users/{id}  → 200 (AppUser atualizado)
    func updateUserProfile(
        userId: String,
        name: String,
        description: String?,
        phone: String?,
        photoUrl: String?
    ) -> AnyPublisher<AppUser, AppError>
}

