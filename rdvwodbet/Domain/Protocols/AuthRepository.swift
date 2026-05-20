import Foundation
import Combine

protocol AuthRepository {
    func observeAuthState() -> AnyPublisher<String?, Never>
    func signIn(email: String, password: String) -> AnyPublisher<String, AppError>
    func signUp(email: String, password: String) -> AnyPublisher<String, AppError>
    func sendPasswordReset(email: String) -> AnyPublisher<Void, AppError>
    func signInWithApple(idToken: String, nonce: String) -> AnyPublisher<String, AppError>
    func signOut() throws
    func currentUID() -> String?
}
