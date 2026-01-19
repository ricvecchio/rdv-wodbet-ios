import Foundation
import Combine

protocol AuthRepository {
    func observeAuthState() -> AnyPublisher<String?, Never>
    func signInWithApple(idToken: String, nonce: String) -> AnyPublisher<String, AppError> // retorna uid
    func signOut() throws
    func currentUID() -> String?
}
