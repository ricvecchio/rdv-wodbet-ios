import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: UseCase de login via telefone (backend Java).
// Chama POST /users/login e retorna .loggedIn(AuthSession) ou .codeRequired.

final class LoginWithPhoneUseCase {

    private let repository: PhoneAuthRepositoryProtocol

    init(repository: PhoneAuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(phone: String, uuid: String) -> AnyPublisher<PhoneLoginResult, AppError> {
        repository.loginWithPhone(phone: phone, uuid: uuid)
    }
}

