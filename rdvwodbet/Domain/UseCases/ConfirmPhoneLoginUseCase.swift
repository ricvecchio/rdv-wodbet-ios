import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: UseCase de confirmação do código via telefone (backend Java).
// Chama POST /users/confirm e retorna JWT + usuário ativado/criado.

final class ConfirmPhoneLoginUseCase {

    private let repository: PhoneAuthRepositoryProtocol

    init(repository: PhoneAuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(phone: String, uuid: String, code: String) -> AnyPublisher<AuthSession, AppError> {
        repository.confirmPhone(phone: phone, uuid: uuid, code: code)
    }
}

