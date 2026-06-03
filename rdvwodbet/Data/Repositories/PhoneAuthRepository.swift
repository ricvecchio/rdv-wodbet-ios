import Foundation
import Combine

// ⚠️ ENTREGA ACADÊMICA: Repositório de autenticação por telefone via backend Java.
// Implementa PhoneAuthRepositoryProtocol (domínio) e usa PhoneAuthRemoteDataSource (dados).
// Converte DTOs brutos em entidades de domínio (AppUser) via BackendUserMapper.

final class PhoneAuthRepository: PhoneAuthRepositoryProtocol {

    private let remoteDataSource: PhoneAuthRemoteDataSource

    init(remoteDataSource: PhoneAuthRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    // MARK: - PhoneAuthRepositoryProtocol

    func loginWithPhone(phone: String, uuid: String) -> AnyPublisher<PhoneLoginResult, AppError> {
        remoteDataSource.loginWithPhone(phone: phone, uuid: uuid)
            .map { rawResult -> PhoneLoginResult in
                switch rawResult {
                case .loggedIn(let dto):
                    // PhoneLoginRawResult.loggedIn contém BackendUserDTO — mapeia para AppUser
                    return .loggedIn(BackendUserMapper.toDomain(dto))
                case .codeRequired:
                    return .codeRequired
                }
            }
            .eraseToAnyPublisher()
    }

    func confirmPhone(phone: String, uuid: String, code: String) -> AnyPublisher<AppUser, AppError> {
        remoteDataSource.confirmPhone(phone: phone, uuid: uuid, code: code)
            .map { BackendUserMapper.toDomain($0) }
            .eraseToAnyPublisher()
    }

    func updateUserProfile(userId: String, name: String, description: String?) -> AnyPublisher<AppUser, AppError> {
        remoteDataSource.updateUserProfile(userId: userId, name: name, description: description)
            .map { BackendUserMapper.toDomain($0) }
            .eraseToAnyPublisher()
    }
}
