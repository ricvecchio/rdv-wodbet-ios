import Foundation
import Combine

final class FirestoreUserRepository: UserRepository {
    private let dataSource: FirestoreUserDataSource

    init(dataSource: FirestoreUserDataSource) {
        self.dataSource = dataSource
    }

    func fetchUser(uid: String) -> AnyPublisher<AppUser?, AppError> {
        dataSource.fetchUser(uid: uid)
            .map { dto in dto.map(AppUserMapper.toDomain) }
            .eraseToAnyPublisher()
    }

    func createUserIfNeeded(uid: String, displayName: String, photoURL: String?) -> AnyPublisher<Void, AppError> {
        let data = AppUserMapper.toFirestore(displayName: displayName, photoURL: photoURL)
        return dataSource.upsertUser(uid: uid, data: data)
    }

    func updateDisplayName(uid: String, displayName: String) -> AnyPublisher<Void, AppError> {
        return dataSource.upsertUser(uid: uid, data: ["displayName": displayName])
    }

    func observeAllUsers() -> AnyPublisher<[AppUser], AppError> {
        dataSource.observeAllUsers()
            .map { $0.map(AppUserMapper.toDomain) }
            .eraseToAnyPublisher()
    }
}
