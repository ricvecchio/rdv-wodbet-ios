import Foundation
import Combine

final class FirebaseAuthRepository: AuthRepository {
    private let dataSource: FirebaseAuthDataSource

    init(dataSource: FirebaseAuthDataSource) {
        self.dataSource = dataSource
    }

    func observeAuthState() -> AnyPublisher<String?, Never> {
        dataSource.observeAuthState()
    }

    func signInWithApple(idToken: String, nonce: String) -> AnyPublisher<String, AppError> {
        // Implementaremos no próximo passo (Sign in with Apple + Firebase)
        return Fail(error: .invalidInput("Sign in with Apple ainda não implementado."))
            .eraseToAnyPublisher()
    }

    func signOut() throws {
        try dataSource.signOut()
    }

    func currentUID() -> String? {
        dataSource.currentUID()
    }
}
