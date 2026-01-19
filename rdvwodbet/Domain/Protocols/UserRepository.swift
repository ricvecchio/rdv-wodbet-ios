import Foundation
import Combine

protocol UserRepository {
    func fetchUser(uid: String) -> AnyPublisher<AppUser?, AppError>
    func createUserIfNeeded(uid: String, displayName: String, photoURL: String?) -> AnyPublisher<Void, AppError>
    func updateDisplayName(uid: String, displayName: String) -> AnyPublisher<Void, AppError>
    func observeAllUsers() -> AnyPublisher<[AppUser], AppError>
}
