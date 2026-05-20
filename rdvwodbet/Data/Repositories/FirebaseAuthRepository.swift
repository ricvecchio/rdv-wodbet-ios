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

    func signIn(email: String, password: String) -> AnyPublisher<String, AppError> {
        dataSource.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) -> AnyPublisher<String, AppError> {
        dataSource.signUp(email: email, password: password)
    }

    func sendPasswordReset(email: String) -> AnyPublisher<Void, AppError> {
        dataSource.sendPasswordReset(email: email)
    }

    func signInWithApple(idToken: String, nonce: String) -> AnyPublisher<String, AppError> {
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
