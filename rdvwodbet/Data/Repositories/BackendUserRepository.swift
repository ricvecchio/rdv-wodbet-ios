import Foundation
import Combine

final class BackendUserRepository: UserRepository {
    private let remoteDataSource: BackendUserRemoteDataSource

    init(remoteDataSource: BackendUserRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchUser(uid: String) -> AnyPublisher<AppUser?, AppError> {
        remoteDataSource.fetchUser(id: uid)
            .map { dto in
                dto.map { BackendUserMapper.toDomain($0) }
            }
            .eraseToAnyPublisher()
    }

    func createUserIfNeeded(uid: String, displayName: String, photoURL: String?) -> AnyPublisher<Void, AppError> {
        remoteDataSource.upsertUser(id: uid, name: displayName, description: nil, phone: nil, photoUrl: photoURL)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func updateDisplayName(uid: String, displayName: String) -> AnyPublisher<Void, AppError> {
        remoteDataSource.upsertUser(id: uid, name: displayName, description: nil, phone: nil, photoUrl: nil)
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func observeAllUsers() -> AnyPublisher<[AppUser], AppError> {
        remoteDataSource.fetchUsers()
            .map { dtos in
                dtos.map { BackendUserMapper.toDomain($0) }
            }
            .eraseToAnyPublisher()
    }
}

