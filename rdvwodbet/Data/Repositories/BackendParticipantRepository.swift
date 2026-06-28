import Foundation
import Combine

final class BackendParticipantRepository: ParticipantRepository {
    private let remoteDataSource: BackendParticipantRemoteDataSource

    init(remoteDataSource: BackendParticipantRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchParticipant(id: String) -> AnyPublisher<Participant?, AppError> {
        remoteDataSource.fetchParticipant(id: id)
            .map { dto in
                dto.map { ParticipantBackendMapper.toDomain($0) }
            }
            .eraseToAnyPublisher()
    }

    func observeParticipants() -> AnyPublisher<[Participant], AppError> {
        remoteDataSource.fetchParticipants()
            .map { dtos in
                dtos.map { ParticipantBackendMapper.toDomain($0) }
            }
            .eraseToAnyPublisher()
    }

    func createParticipant(name: String, email: String?, phone: String?) -> AnyPublisher<Void, AppError> {
        remoteDataSource.createParticipant(name: name, email: email, phone: phone)
    }

    func updateParticipant(id: String, name: String?, phone: String?) -> AnyPublisher<Void, AppError> {
        remoteDataSource.updateParticipant(id: id, name: name, phone: phone)
    }
}

