import Foundation
import Combine

final class ObserveAuthStateUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func execute() -> AnyPublisher<String?, Never> {
        authRepository.observeAuthState()
    }
}
