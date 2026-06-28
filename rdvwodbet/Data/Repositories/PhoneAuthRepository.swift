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
                case .loggedIn(let session):
                    return .loggedIn(
                        AuthSession(
                            jwt: session.jwt,
                            user: BackendUserMapper.toDomain(session.user),
                            phone: session.user.phone,
                            uuid: session.user.uuid ?? uuid
                        )
                    )
                case .codeRequired:
                    return .codeRequired
                }
            }
            .eraseToAnyPublisher()
    }

    func confirmPhone(phone: String, uuid: String, code: String) -> AnyPublisher<AuthSession, AppError> {
        remoteDataSource.confirmPhone(phone: phone, uuid: uuid, code: code)
            .map { session in
                AuthSession(
                    jwt: session.jwt,
                    user: BackendUserMapper.toDomain(session.user),
                    phone: session.user.phone,
                    uuid: session.user.uuid ?? uuid
                )
            }
            .eraseToAnyPublisher()
    }

    func updateUserProfile(
        userId: String,
        name: String,
        description: String?,
        phone: String?,
        photoUrl: String?
    ) -> AnyPublisher<AppUser, AppError> {
        remoteDataSource.updateUserProfile(
            userId: userId,
            name: name,
            description: description,
            phone: phone,
            photoUrl: photoUrl
        )
            .map { BackendUserMapper.toDomain($0) }
            .eraseToAnyPublisher()
    }
}
