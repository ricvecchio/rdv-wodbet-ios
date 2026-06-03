import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: UseCase de confirmação do código via telefone (backend Java).
// Chama POST /users/confirm e retorna o AppUser ativado/criado.

final class ConfirmPhoneLoginUseCase {

    private let repository: PhoneAuthRepositoryProtocol

    init(repository: PhoneAuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(phone: String, uuid: String, code: String) -> AnyPublisher<AppUser, AppError> {
        repository.confirmPhone(phone: phone, uuid: uuid, code: code)
    }
}

