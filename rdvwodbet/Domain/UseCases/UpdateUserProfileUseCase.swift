import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: UseCase para atualizar o perfil do usuário via backend Java.
// Chama PUT /users/{id} e retorna o AppUser atualizado.

final class UpdateUserProfileUseCase {

    private let repository: PhoneAuthRepositoryProtocol

    init(repository: PhoneAuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String, name: String, description: String? = nil) -> AnyPublisher<AppUser, AppError> {
        repository.updateUserProfile(userId: userId, name: name, description: description)
    }
}

